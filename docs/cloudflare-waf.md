# Cloudflare WAF / bot protection

## WordPress admin/login hardening (gpo.ca zone)

Resources: `tf/infra/singletons/cloudflare_wordpress_admin_protection.tf`

Rules here were derived from the actual `gpo/gpo-ca` source, not a generic
WordPress hardening checklist. Two facts about that codebase drive most of
the design:

- **WP core lives under `/wordpress`.** `WP_SITEURL` is
  `https://gpo.ca/wordpress`, so the real login is
  `/wordpress/wp-login.php` and the real admin is `/wordpress/wp-admin/`.
  Rules matching bare `/wp-login.php` protect nothing. Both forms are
  matched: the bare paths don't exist, but `web/.htaccess` funnels unknown
  paths into `index.php`, so blocking scanner probes at the edge saves the
  origin a PHP bootstrap each time.
- **`secure.gpo.ca` is Drupal + CiviCRM, not WordPress.** None of these
  rules protect it. See the open items below.

### Layers

1. **Bot Fight Mode** (`cloudflare_bot_management.gpo_ca`) — zone-wide,
   available on every plan tier.
2. **Rate limiting** (`cloudflare_ruleset.gpo_ca_wp_login_rate_limit`) —
   blocks a source IP for 10 minutes after 5 POSTs to the login path in 60
   seconds. Tunable via the `wp_login_rate_limit_*` locals.
3. **WAF custom rules** (`cloudflare_ruleset.gpo_ca_admin_route_protection`):

   | Rule | Action | Why it's safe |
   |---|---|---|
   | Unused endpoints: `xmlrpc.php`, `wp-comments-post.php`, `wp-signup.php`, `wp-register.php`, `/trackback` | block | XML-RPC isn't disabled anywhere in code and nothing calls it; `comments_open` is filtered to `__return_false` site-wide; there's no public registration |
   | User enumeration: `/wp-json/wp/v2/users`, `?author=<id>` | block | The only REST namespace the front end uses is `gpo-action-blocks/v1`; the theme never queries users or author archives |
   | PHP under `/uploads/` | block | `CONTENT_DIR` is `""` so media sits at `/uploads`, and `web/.htaccess` has no PHP-execution guard there |
   | Admin/login surfaces | managed challenge | Front end is fully anonymous — no `is_user_logged_in`/`wp_login_url` anywhere in the theme, so only staff hit these |
   | Non-CA traffic to admin surfaces | managed challenge | **disabled by default**, see below |

`/wordpress/wp-admin/admin-ajax.php` is deliberately excluded from the admin
rule. Third-party plugins (Gravity Forms, Popup Maker, TotalContest) are
Composer-installed rather than vendored, so their front-end AJAX use can't be
ruled out from the repo. Verify against a running site before tightening.

### Already handled in code — no edge rule needed

Checked and confirmed already disabled in `gpo/gpo-ca`, so adding Cloudflare
rules for them would be redundant: RSS/Atom feeds (`do_feed*` hooked to an
early exit), comments, the generator meta tag, emoji scripts, and
`DISALLOW_FILE_MODS` on production. `web/.htaccess` additionally denies
`wp-config.php`, `readme.html`, `license.txt`, dotfiles, `repair.php`,
`wp-mail.php`, `wp-includes/*.php`, and TRACE/TRACK/DELETE methods.

### Open items

- **Plan tier and rule budget.** The custom ruleset is currently 5 rules,
  which is exactly the Cloudflare Free-plan ceiling, and Free allows only one
  rate-limiting rule. Confirm the zone's plan before adding more. Pro+ also
  unlocks Super Bot Fight Mode (`sbfm_*` and `optimize_wordpress` on
  `cloudflare_bot_management`), which is WordPress-aware and worth enabling.
- **Unauthenticated CiviCRM write endpoints are unprotected.** Both
  `/wp-json/gpo-action-blocks/v1/*` (email-action, download-action,
  call-mpp-action, all `permission_callback => __return_true`) and the
  `/api/*.php` form handlers create CiviCRM contacts and send mail with no
  captcha, nonce, or throttle. Turnstile covers Gravity Forms only, not
  these. This is arguably a higher-value target than the login page and
  wants its own rate-limit rule — blocked on the plan-tier question above.
- **`secure.gpo.ca` (Drupal/CiviCRM) has no equivalent protection.** Its
  admin surfaces are `/user/login`, `/user/password`, and `/civicrm/*`.
  Needs its own ruleset; the WordPress paths here don't apply.
- **Don't block `/wp-cron.php` at the edge.** `DISABLE_WP_CRON` isn't set
  and there's no system cron, so WP spawns cron via a loopback request to
  `WP_SITEURL` — which resolves through Cloudflare. Blocking it would
  silently break scheduled jobs. Set `DISABLE_WP_CRON` and move to a real
  cron (`wp cron event run --due-now`) first, then block it.
- **Geo-scoping to Canada.** `local.restrict_admin_routes_to_canada` adds a
  managed challenge (not a hard block) for non-CA traffic to admin routes,
  additive to the layers above. Defaults to `false`. A challenge was chosen
  over a block so a travelling admin can still get through, standing in for
  a proper exception process. Before enabling, confirm that's acceptable or
  design a dedicated mechanism (temporary IP allowlist, or a Cloudflare
  Access policy on admin routes instead of geo-matching).
