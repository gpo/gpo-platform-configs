# Cloudflare WAF rules: design doc

Issue: [#202](https://github.com/gpo/gpo-platform-configs/issues/202)

## Context

gpo.ca is a Bedrock-style WordPress install where WP core lives under
`/wordpress/` (`WP_SITEURL=https://gpo.ca/wordpress`). The same Cloudflare
zone also serves `secure.gpo.ca`, a Drupal + CiviCRM site with a completely
different admin surface. The zone is on the Cloudflare Free plan.

This doc covers how to write Cloudflare edge rules for the WordPress site
only. `secure.gpo.ca` needs its own ruleset and is out of scope here.

## Goals

1. **Reduce the attack surface that ships with WordPress by default.** Block
   or challenge paths that are unused but routinely probed (xmlrpc, comments,
   signup, user enumeration). The intent is defence in depth: even if origin
   code already disables a feature, blocking it at the edge eliminates a class
   of future regressions (e.g., a plugin re-enabling XML-RPC).
2. **Raise the cost of credential stuffing against `/wp-login.php`.** Rate
   limiting and managed challenges make brute-force attacks slow and
   expensive without affecting the small number of legitimate staff logins.
3. **Block known-dangerous upload patterns.** The Bedrock layout puts media at
   `/uploads/` with no `.htaccess` PHP execution guard, so an upload-to-RCE
   chain is the highest-impact exploit to prevent at the edge.
4. **Make the rule set auditable from source.** Every rule should trace back
   to a verified fact about the `gpo/gpo-ca` codebase, not a generic
   WordPress hardening checklist.

## Non-goals

- **Protecting `secure.gpo.ca`.** Different application, different admin
  surface (`/user/login`, `/civicrm/*`), needs its own design.
- **Replacing origin-level security.** Cloudflare rules are a layer, not a
  substitute. `.htaccess` rules, `DISALLOW_FILE_MODS`, and application-level
  auth remain the primary controls.
- **Full allowlist at the edge.** An allowlist ("block everything except known
  good paths") would be the strongest posture, but it's impractical without
  a complete inventory of every URL the front end and third-party plugins
  serve. See Option C below.
- **Rate limiting CiviCRM write endpoints.** The unauthenticated
  `/wp-json/gpo-action-blocks/v1/*` and `/api/*.php` endpoints are arguably
  a higher-value target than the login page, but rate limiting them is
  blocked on the Free-plan rule budget (1 rate-limit rule allowed). Tracked
  as an open item.
- **Origin lockdown.** Restricting the origin server to accept connections
  only from Cloudflare IPs (Authenticated Origin Pulls, or firewall rules)
  is important but orthogonal to WAF rule design. Origin IPs are currently
  in plaintext in `cloudflare_domains.tf`.

## Constraints

### Cloudflare Free plan limits

| Resource | Free-plan limit |
|---|---|
| Custom WAF rules (`http_request_firewall_custom`) | 5 |
| Rate-limiting rules (`http_ratelimit`) | 1 |
| Bot Fight Mode | available (basic) |
| Super Bot Fight Mode (`sbfm_*`, `optimize_wordpress`) | Pro+ only |
| Cloudflare Access (Zero Trust) | requires separate plan |

The current implementation uses exactly 5 WAF rules and 1 rate-limit rule,
which means **the Free plan is fully consumed**. Adding any new rule requires
either upgrading the plan, consolidating existing rules, or moving logic to
the origin.

### Bedrock layout

WP core is at `/wordpress/`, so the real admin surface is
`/wordpress/wp-admin/` and `/wordpress/wp-login.php`. The bare `/wp-*` paths
don't serve anything, but `.htaccess` routes unknown paths into `index.php`,
costing a PHP bootstrap per probe. Rules match both path variants.

### `admin-ajax.php` must stay open

Third-party plugins (Gravity Forms, Popup Maker, TotalContest) are
Composer-installed and gitignored. Their front-end AJAX use can't be ruled
out from the repo. Challenging `admin-ajax.php` risks breaking public-facing
forms.

### `wp-cron.php` must stay open

`DISABLE_WP_CRON` is not set and there's no system cron. WordPress spawns
cron via a loopback request to `WP_SITEURL`, which resolves through
Cloudflare. Blocking it would silently break scheduled jobs.

### Singletons stack is production-only

The `tf/infra/singletons` stack has no staging equivalent. Every `tofu apply`
changes the live zone. Rules must be conservative, and new rules should be
deployed `enabled = false` first where practical.

### Shared zone with `secure.gpo.ca`

Zone-wide settings (Bot Fight Mode) affect both sites. Hostname-scoped rules
must use `http.host eq "gpo.ca"` or path prefixes that don't collide with
Drupal routes.

## What's already verified against `gpo/gpo-ca` source

These facts were confirmed by reading the codebase, not assumed from a
generic checklist:

| Feature | Status | Source |
|---|---|---|
| XML-RPC | Not disabled in code, nothing calls it | No `add_filter('xmlrpc_enabled', ...)` found |
| Comments | `comments_open` filtered to `__return_false` | `functions.php:2505` |
| RSS/Atom feeds | All `do_feed*` hooks exit early | `functions.php:2170-2196` |
| Public registration | No public signup; staff-only accounts | No registration form in theme |
| REST users endpoint | Not used by front end | Only REST namespace used: `gpo-action-blocks/v1` |
| Author archives | Not linked anywhere in theme | No `?author=` links |
| `is_user_logged_in` in theme | Not present | Grep confirms zero matches |
| `.htaccess` PHP guards | Blocks `wp-config.php`, `readme.html`, dotfiles, `repair.php`, `wp-mail.php`, `wp-includes/*.php`, TRACE/TRACK/DELETE | `web/.htaccess` |
| `.htaccess` uploads guard | **Missing** | No rule preventing PHP execution under `/uploads/` |
| `DISALLOW_FILE_MODS` | Set on production | `wp-config.php:47-49` |
| `DISABLE_WP_CRON` | **Not set** | Grep confirms zero matches |

## Options

### Option A: denylist in platform-configs (current PR #203)

Keep the rules in `tf/infra/singletons/` as a denylist: block/challenge
specific known-bad paths, leave everything else open.

**What's in the current implementation:**

| # | Rule | Action |
|---|---|---|
| 1 | Unused endpoints (xmlrpc, comments, signup, trackback) | block |
| 2 | User enumeration (REST users, `?author=N`) | block |
| 3 | Admin/login surfaces (with `admin-ajax.php` excluded) | managed_challenge |
| 4 | PHP execution under `/uploads/` | block |
| 5 | Non-CA traffic to admin (disabled by default) | managed_challenge |
| R1 | POST `/wp-login.php` rate limit (5/min/IP, 10min block) | block |

**Pros:**

- Already implemented and reviewed against the actual codebase.
- Conservative: won't break anything that works today.
- Lives in the infra repo where other Cloudflare config already lives
  (DNS, Pages, zones).
- Rules are auditable via the same PR/review process as other infra changes.

**Cons:**

- Denylist is inherently incomplete. New WordPress features, plugin routes,
  or overlooked paths won't be covered until someone adds a rule.
- Coupled to knowledge of the WordPress codebase. When `gpo-ca` changes
  (new plugin, new endpoint), the rules here may need updating, but nothing
  enforces that.
- Free-plan ceiling is already hit. No room for the CiviCRM rate-limit rule
  or any new protection without consolidation or a plan upgrade.

**When to pick this:** The threat model is "block the known-bad stuff that
scanners hit" and the team accepts that new attack surface from future
WordPress/plugin changes won't be covered at the edge until manually added.

### Option B: denylist in `gpo-ca` repo, deployed via CI

Move the Cloudflare rules into the `gpo/gpo-ca` repo (as a Terraform module
or a standalone config), deployed by `gpo-ca`'s CI pipeline. The
platform-configs repo would still own the zone and DNS, but the WAF rules
would live alongside the application code.

**Pros:**

- Rules and the code they protect are in the same repo. A PR that adds a
  plugin can also update the WAF rules.
- Developers working on `gpo-ca` can see and modify the rules without
  touching the infra repo.
- Easier to keep rules in sync with the application.

**Cons:**

- Requires wiring Cloudflare provider credentials into `gpo-ca` CI, which
  currently only deploys application code.
- Splits Cloudflare config across two repos (zone/DNS in platform-configs,
  WAF in gpo-ca). Debugging requires checking both.
- The `gpo-ca` repo has no Terraform/OpenTofu setup today; this would be
  a new capability to introduce and maintain.
- Still a denylist with the same incompleteness problem.

**When to pick this:** The team frequently changes plugins or endpoints and
wants WAF rules reviewed in the same PR as the application change.

### Option C: origin-level allowlist (`.htaccess` or nginx)

Instead of (or in addition to) Cloudflare rules, enforce an allowlist at the
origin. Only serve paths that match known routes; return 403 for everything
else. This could be done in `.htaccess` (already used) or by switching to
nginx (the DDEV config already uses nginx).

**Pros:**

- Strongest security posture: unknown paths are denied by default.
- Not constrained by Cloudflare rule limits.
- Lives in the application repo, naturally versioned with the code.
- Catches internal requests (loopback, cron) that bypass Cloudflare.

**Cons:**

- Hard to build a complete allowlist. WordPress core, plugins, and themes
  register routes dynamically. Missing a legitimate path breaks
  functionality silently.
- Every PHP bootstrap to serve a 403 still costs CPU. Cloudflare rules
  avoid this by rejecting at the edge.
- Composer-installed plugins are gitignored, so their routes aren't visible
  in the repo. Building the allowlist requires runtime inspection of a
  running site (e.g., `wp route list`, REST API discovery).
- Ongoing maintenance burden: every new plugin, block, or endpoint needs an
  allowlist update.

**When to pick this:** The site is stable, plugins change rarely, and the
team is willing to invest in building and maintaining a comprehensive route
inventory.

### Option D: hybrid (recommended)

Use Cloudflare for **infra-level protections** that don't depend on
application knowledge, and handle **application-aware restrictions** at the
origin or via CI-deployed rules.

**In platform-configs (Cloudflare, infra-level):**

- Bot Fight Mode (zone-wide, no rule budget cost)
- Block PHP execution under `/uploads/` (universally dangerous, unlikely to
  change)
- Rate limit POST to login paths (generic anti-brute-force)
- Managed challenge on admin/login surfaces (protects all WordPress admin
  paths)

**In `gpo-ca` or as follow-up issues:**

- Block/allow specific endpoints (xmlrpc, comments, signup, REST users) via
  `.htaccess` or application code, since these depend on what the app
  actually uses
- Rate limit CiviCRM write endpoints at the origin (not constrained by
  Free-plan limits)
- Fix the `X-Forwarded-For` trust bug in `class.gpo.utils.php` so
  origin-level rate limiting works correctly
- Add `.htaccess` PHP execution guard for `/uploads/` as defence in depth
  (belt and suspenders with the Cloudflare rule)

**Pros:**

- Separates concerns: infra rules are stable and don't need application
  knowledge; application rules live with the application.
- Frees Cloudflare rule budget for the protections that genuinely benefit
  from edge enforcement (rate limiting, upload blocking, bot challenges).
- Application-specific blocks (xmlrpc, comments, user enum) can be more
  easily maintained where the context is.
- Unblocks CiviCRM endpoint protection without waiting for a plan upgrade.

**Cons:**

- Two places to look for security rules.
- Requires work in `gpo-ca` repo (`.htaccess` changes, XFF fix) that's
  outside the scope of this issue.
- Origin-level blocks still cost a PHP bootstrap (for paths that
  `.htaccess` doesn't catch before `index.php`).

**When to pick this:** The team wants the strongest practical posture without
being blocked on Cloudflare plan limits, and is willing to split the work
across repos.

## Recommendation

**Option D (hybrid)**, implemented in two phases:

**Phase 1** (this PR, platform-configs): Trim the current ruleset to the 4
infra-level rules that don't depend on application knowledge:

1. Managed challenge on admin/login surfaces
2. Block PHP under `/uploads/`
3. Rate limit POST to login paths
4. Bot Fight Mode (no rule budget cost)

This leaves 1 Free-plan WAF rule slot open for future use (e.g., geo-scoping
when the travelling-admin process is agreed on).

**Phase 2** (follow-up issues in `gpo-ca`): Move application-specific blocks
to `.htaccess` and fix the gaps:

- Block xmlrpc, comments, signup, trackback, user enumeration at the origin
- Add `.htaccess` PHP execution guard for `/uploads/`
- Fix `X-Forwarded-For` trust bug in `class.gpo.utils.php`
- Rate limit CiviCRM write endpoints at the origin
- Investigate `DISABLE_WP_CRON` + system cron to unblock blocking
  `wp-cron.php` at the edge

## Open questions

1. **What Cloudflare plan is the zone actually on?** The implementation
   assumes Free. If Pro or higher, Super Bot Fight Mode and additional rule
   slots are available, which changes the calculus.
2. **Is the origin IP restricted to Cloudflare ranges?** If not, all edge
   rules can be bypassed by hitting the origin directly. Origin IPs are in
   plaintext in `cloudflare_domains.tf`.
3. **Does `admin-ajax.php` actually receive front-end traffic?** Verifiable
   by checking Cloudflare analytics or server logs. If not, it can be added
   to the challenge rule.
4. **Is a Cloudflare plan upgrade on the table?** Pro unlocks Super Bot Fight
   Mode (`optimize_wordpress`), more WAF rule slots, and more rate-limit
   rules, which would let all of Options A through D work more comfortably.
