# Cloudflare WAF: admin protection for gpo.ca and secure.gpo.ca

Resources: `tf/infra/singletons/cloudflare_wordpress_admin_protection.tf` — one custom ruleset and one rate-limit ruleset covering both sites on the gpo.ca zone. All admins are in Ontario, so admin surfaces are hard-blocked from outside Canada (province-level matching needs a Business plan, see constraints).

Everything here was derived from the actual sources (`gpo/gpo-ca`, `gpo/secure-gpo-ca`, and the prod nginx config in `gpo/etc-prod1.gpo.ca`), not a generic hardening checklist. An earlier design doc weighed edge-versus-origin placements; the outcome is this hybrid: app-verifiable facts enforced at the edge here, endpoint policy enforced in code (`gpo-ca`'s `web/mu-plugins/gpo-anonymous-surface-guard.php` default-denies anonymous admin-ajax/REST).

## Hard constraints (zone is confirmed Free plan)

- **Budget: 5 custom rules + 1 rate-limit rule per zone**, shared by gpo.ca and secure.gpo.ca. All slots are used; anything new must fit this file's single ruleset per phase (Cloudflare allows one `cloudflare_ruleset` per zone per phase).
- **No regex.** The `matches` operator is Business+; expressions use only `eq`/`in`/`starts_with`/`ends_with`/`contains`.
- **No province-level geo.** `ip.src.region_code` is Business+; geo rules use `ip.src.country ne "CA"`. Tighten to `eq "ON"` if the zone is ever upgraded.
- **Universal SSL covers only `gpo.ca` and `*.gpo.ca`** — second-level names like `staging.secure.gpo.ca` cannot be proxied without an ACM cert.

## The rules

Rate limit (the single slot): block an IP for 10 minutes after 5 POSTs in 60 seconds to any of `wp-login.php` or `/api/*` (gpo.ca hosts) or `/user/login` (secure hosts), counted together. `/api/*` is included because those form handlers create CiviCRM contacts and send mail with no captcha; legitimate users never POST 5 times a minute across these. Tunable via `wp_login_rate_limit_*` locals.

| # | Rule | Action | Why it's safe |
|---|---|---|---|
| 1 | Unused WP endpoints: `xmlrpc.php`, `wp-comments-post.php`, `wp-signup/register.php`, `/trackback` | block | nothing calls XML-RPC; comments are filtered off site-wide; no public registration |
| 2 | WP user enumeration: `/wp-json/wp/v2/users`, `?author=<id>` | block | the front end only uses the `gpo-action-blocks/v1` REST namespace |
| 3 | Non-CA traffic to admin surfaces, both sites | block | see path lists below; agreed policy |
| 4 | WP admin/login surfaces | managed challenge | front end is fully anonymous; only staff hit these |
| 5 | PHP under upload dirs: `/uploads/` (gpo.ca), `/sites/default/files/` (secure) | block | media dirs; nothing legitimate serves PHP from them |

Path facts baked into the expressions:

- gpo.ca is Bedrock-style: the real admin surface is `/wordpress/wp-admin` and `/wordpress/wp-login.php`. Bare `/wp-*` paths 404 at the origin (nginx, no alias) but are matched anyway for scanner absorption. `admin-ajax.php` and `/wp-json` are excluded — Gravity Forms, Popup Maker, and TotalContest use them anonymously (policy for those lives in the gpo-ca mu-plugin).
- secure.gpo.ca (Drupal + CiviCRM) admin surface: `/admin*`, `/user/login`, `/civicrm/admin*`, `/civicrm/a/*`. **Never extend the block to** `/civicrm/contribute/*` (donations), `/civicrm/payment/ipn*` (PayPal/iATS callbacks), `/civicrm/extern/*`, `/civicrm/mailing/*` (open/click tracking), `/civicrm/ajax/*`, `/civicrm/event/*`, or `/civicrm/profile/*` — all hit legitimately from outside Canada. These are prefix-disjoint from the blocked paths, so no carve-outs exist in the expressions; keep it that way.

Bot Fight Mode is deliberately absent: zone-wide, unscopable, unbypassable, and would hit secure.gpo.ca's CiviCRM API/webhook traffic with no staged rollout. Enable it only as its own decision.

## Staged rollout

Singletons has no stage tier, so staging happens inside the zone via two independent `http.host in {…}` lists:

- `waf_enforced_hosts = ["staging.gpo.ca"]` — WordPress rules. Phase 2 (follow-up PR after verification): add `"gpo.ca"` and `"www.gpo.ca"`. Nothing else changes, so staging ran exactly what prod gets.
- `secure_admin_geo_hosts = ["staging.secure.gpo.ca"]` — secure branch of rules 3/5 and the rate limit. Phase 2: add `"secure.gpo.ca"`. **Currently blocked**: no edge cert for the second-level staging hostname (record left unproxied). Options: ACM (~$10 USD/mo, `*.secure.gpo.ca`); rename to first-level `staging-secure.gpo.ca` (free, needs origin vhost + cert); or skip staging for this branch and enable on `secure.gpo.ca` with a human watching the donation flow.

### Verification, phase 1

staging.gpo.ca: public pages and `/wp-json/gpo-action-blocks/v1/*` unaffected; `/wordpress/wp-login.php` challenges then works from a Canadian IP and blocks from a non-CA VPN; 6 rapid login POSTs trip the rate limit; `xmlrpc.php` blocked on both path forms.

staging.secure (once unblocked): site loads over the proxy (origin cert must satisfy the zone SSL mode); admin paths blocked from non-CA; a donation page stays reachable from non-CA.

## Origin lockdown

prod1 drops 80/443 traffic that isn't from Cloudflare's published ranges (iptables + ipsets under `/etc/ipset/`, refreshed nightly), so these edge rules can't be bypassed via the origin IP. The staging origin `137.184.128.54` has NOT been verified — until someone with SSH confirms it matches prod1, treat staging as reachable by direct IP.

## Open items

- **Unauthenticated CiviCRM write endpoints**: `/api/*` POSTs are now edge-rate-limited (rule above) and the SQLi in `find-riding.php` is fixed in gpo-ca, but the form handlers and `/wp-json/gpo-action-blocks/v1/*` still lack captcha; Turnstile covers Gravity Forms only. App-layer Turnstile is the remaining work (tracked in gpo-ca).
- **Don't block `/wp-cron.php`**: `DISABLE_WP_CRON` isn't set and there's no system cron, so WP triggers cron via a loopback request through Cloudflare. Move to real cron first.
- **App-layer client IP trust**: resolved — `getUserIPAddress()` returns only `REMOTE_ADDR` (which nginx restores from Cloudflare via `real-ip.conf`), merged in gpo-ca along with the `find-riding.php` SQLi fix.
- **Travelling admins** are hard-blocked from outside Canada: temporary edit here, a Canadian VPN egress, or replace the geo rule with a Cloudflare Access policy.
- **ontariogreens.ca needs nothing**: its zone 301-deep-redirects to gpo.ca at the edge (path + query preserved) and its DNS never reaches the origin; the nginx server_name entry for it is vestigial. Already-handled-in-code items needing no edge rule: feeds, comments, generator tag, emoji scripts, `DISALLOW_FILE_MODS`, and the gpo-ca mu-plugin's anonymous-surface allowlists.
