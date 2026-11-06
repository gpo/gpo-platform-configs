# Cloudflare WAF: admin protection for gpo.ca and secure.gpo.ca

Resources: `tf/infra/singletons/cloudflare_wordpress_admin_protection.tf` — one custom ruleset and one rate-limit ruleset covering both sites on the gpo.ca zone. All admins are in Ontario, so admin surfaces are hard-blocked from outside Canada (province-level matching needs a Business plan, see constraints).

Everything here was derived from the actual sources (`gpo/gpo-ca`, `gpo/secure-gpo-ca`, and the prod nginx config in `gpo/etc-prod1.gpo.ca`), not a generic hardening checklist. An earlier design doc weighed edge-versus-origin placements; the outcome is this hybrid: app-verifiable facts enforced at the edge here, endpoint policy enforced in code (`gpo-ca`'s `web/mu-plugins/gpo-anonymous-surface-guard.php` default-denies anonymous admin-ajax/REST).

## Hard constraints (zone is confirmed Free plan)

- **Budget: 5 custom rules + 1 rate-limit rule per zone**, shared by gpo.ca and secure.gpo.ca. All slots are used; anything new must fit this file's single ruleset per phase (Cloudflare allows one `cloudflare_ruleset` per zone per phase).
- **No regex.** The `matches` operator is Business+; expressions use only `eq`/`in`/`starts_with`/`ends_with`/`contains`.
- **No province-level geo.** `ip.src.region_code` is Business+; geo rules use `ip.src.country ne "CA"`. Tighten to `eq "ON"` if the zone is ever upgraded.
- **Rate-limit rules are entitled to a 10-second counting window only, and the mitigation timeout is pinned to match it.** `period=60` and `mitigation_timeout=600` are both rejected at apply; Free-plan rules are burst limiters (10s window, 10s block), not lockouts — Business+ decouples the two.
- **Universal SSL covers only `gpo.ca` and `*.gpo.ca`** — second-level names like `staging.secure.gpo.ca` cannot be proxied without an ACM cert.

## The rules

**The custom-rule ruleset was not empty when this work started.** The zone already had 3 dashboard-managed rules fighting credit-card-testing fraud on the donation forms. Per the zone owner: the wp2shell REST-batch rule was dropped (stale, superseded by rule 2 below); the IP block and the general geo challenge were kept and folded into this ruleset (rules 1 and 5) since Cloudflare allows only one `http_request_firewall_custom` ruleset per zone. **Importing the existing ruleset is required before `tofu apply` will succeed** — see the comment above `cloudflare_ruleset.gpo_ca_admin_route_protection` in the `.tf` file for the exact `tofu import` command and how to find the ruleset ID.

Rate limit (the single slot): if an IP POSTs more than 5 times in 10 seconds to any of `wp-login.php` or `/api/*` (gpo.ca hosts) or `/user/login`, `/user/password`, or `/civicrm/contribute/transact` (secure hosts), further POSTs to those paths from that IP are blocked for the next 10 seconds. Both numbers are Free-plan ceilings, not a design choice: `period=60` is rejected at apply ("not entitled to use the period 60, can only use a period among [10]"), and so is `mitigation_timeout=600` ("not entitled to use a mitigation timeout different from 10" — Business+ unlocks independent values). This is a burst limiter, not a lockout: it stops scripted rapid-fire submission but not slow, patient brute force. `/civicrm/contribute/transact` is the actual donation charge endpoint — the direct target of the card-testing fraud the pre-existing rules above were built for. `/api/*` is included because those form handlers create CiviCRM contacts and send mail with no captcha. **No IP allowlist**: `ip.src` works as a `characteristics` grouping key on Free plan (already used) but apply rejects it inside the rule's own matching expression ("not entitled: the use of field ip.src is not allowed, an higher Advanced Rate Limiting plan is required"), so a staff/monitoring IP can't be cheaply exempted here. The only Free-plan-compatible route is a dedicated `action = "skip"` rule targeting the `http_ratelimit` phase in the WAF custom-rule ruleset above — which is already at its 5-rule ceiling, so that costs dropping one of the existing 5 rules. `142.93.48.15` was the IP requested for allowlisting; not yet implemented. Tunable via `wp_login_rate_limit_*` locals if the zone is ever upgraded. This rule was created fresh — the zone had 0/1 rate-limit slots used before this work.

Deliberately excluded from the rate limit: `/civicrm/payment/ipn*` (payment-processor webhook callbacks — rate-limiting risks dropping legitimate payment confirmations) and `/civicrm/ajax/*` broadly (client-side form validation can legitimately fire several times in 10 seconds while a donor fills out a form).

| # | Rule | Action | Scope | Why it's safe |
|---|---|---|---|---|
| 1 | Known abusive IPs | block | zone-wide | specific known-bad sources, blocked outright |
| 2 | Unused WP endpoints, user enumeration, PHP under upload dirs | block | WordPress and secure hosts | nothing calls xmlrpc/comments-post/signup/register/trackback; the only REST namespace the front end uses is `gpo-action-blocks/v1`; `author=` is exempt under `/wordpress/wp-admin`, whose post list filters by author; nothing legitimate serves PHP from `/uploads` or `/sites/default/files` |
| 3 | Non-CA traffic to admin surfaces, both sites | block | WordPress and secure hosts | see path lists below; agreed policy |
| 4 | WP admin/login surfaces | managed challenge | WordPress hosts | front end is fully anonymous; only staff hit these |
| 5 | Non-CA/US traffic, zone-wide | managed challenge | zone-wide | general card-testing-fraud mitigation on the donation forms; ordered last so rules 2-4's more specific blocks fire first for admin-path traffic |

Rules 1 and 5 are zone-wide and must not be scoped down to staging hosts, or active fraud protection goes dark on production. Rules 2-4 and the rate limit are host-scoped; see Host scoping below.

Path facts baked into the expressions:

- gpo.ca is Bedrock-style: the real admin surface is `/wordpress/wp-admin` and `/wordpress/wp-login.php`. Bare `/wp-*` paths 404 at the origin (nginx, no alias) but are matched anyway for scanner absorption. `admin-ajax.php` and `/wp-json` are excluded — Gravity Forms, Popup Maker, and TotalContest use them anonymously (policy for those lives in the gpo-ca mu-plugin). GET/HEAD requests for static files under `/wordpress/wp-admin/{js,css,images}/` are excluded as well: public pages load some of them, and a challenge on a script or stylesheet cannot be solved, so it only breaks the page.
- secure.gpo.ca (Drupal + CiviCRM) admin surface: `/admin*`, `/user/login`, `/civicrm/admin*`, `/civicrm/a/*`. **Never extend the block to** `/civicrm/contribute/*` (donations), `/civicrm/payment/ipn*` (PayPal/iATS callbacks), `/civicrm/extern/*`, `/civicrm/mailing/*` (open/click tracking), `/civicrm/ajax/*`, `/civicrm/event/*`, or `/civicrm/profile/*` — all hit legitimately from outside Canada. These are prefix-disjoint from the blocked paths, so no carve-outs exist in the expressions; keep it that way.

Bot Fight Mode is deliberately absent: zone-wide, unscopable, unbypassable, and would hit secure.gpo.ca's CiviCRM API/webhook traffic with no staged rollout. Enable it only as its own decision.

## Host scoping

Rules 2-4 and the rate limit fire only on two `http.host in {…}` lists:

- `waf_enforced_hosts = ["staging.gpo.ca", "gpo.ca", "www.gpo.ca"]`: WordPress rules.
- `secure_admin_geo_hosts = ["staging.secure.gpo.ca", "secure.gpo.ca"]`: secure branch of rules 2 and 3 and the rate limit.

Singletons has no stage tier, so a rule change is staged inside the zone: narrow `waf_enforced_hosts` to `["staging.gpo.ca"]`, apply, verify, then restore the production hosts. Staging and production then run the same expressions.

The secure branch has no staging coverage: `staging.secure.gpo.ca` has no edge cert (second-level name, record left unproxied), so its rules are exercised on `secure.gpo.ca` only. To get staging coverage: ACM (~$10 USD/mo, `*.secure.gpo.ca`), or rename to first-level `staging-secure.gpo.ca` (free, needs origin vhost + cert).

### Verification

WordPress hosts: public pages and `/wp-json/gpo-action-blocks/v1/*` unaffected; `/wordpress/wp-login.php` challenges then works from a Canadian IP and blocks from a non-CA VPN; 6 rapid login POSTs trip the rate limit; `xmlrpc.php` blocked on both path forms; `/wp-json/wp/v2/users` and `/?author=1` blocked; the wp-admin post list still filters by author.

secure.gpo.ca: admin paths blocked from non-CA; a donation page stays reachable from non-CA and a donation completes.

## Origin lockdown

prod1 drops 80/443 traffic that isn't from Cloudflare's published ranges (iptables + ipsets under `/etc/ipset/`, refreshed nightly), so these edge rules can't be bypassed via the origin IP. The staging origin `137.184.128.54` has NOT been verified — until someone with SSH confirms it matches prod1, treat staging as reachable by direct IP.

## Open items

- **Unauthenticated CiviCRM write endpoints**: `/api/*` POSTs are now edge-rate-limited (rule above) and the SQLi in `find-riding.php` is fixed in gpo-ca, but the form handlers and `/wp-json/gpo-action-blocks/v1/*` still lack captcha; Turnstile covers Gravity Forms only. App-layer Turnstile is the remaining work (tracked in gpo-ca).
- **Don't block `/wp-cron.php`**: `DISABLE_WP_CRON` isn't set and there's no system cron, so WP triggers cron via a loopback request through Cloudflare. Move to real cron first.
- **App-layer client IP trust**: resolved — `getUserIPAddress()` returns only `REMOTE_ADDR` (which nginx restores from Cloudflare via `real-ip.conf`), merged in gpo-ca along with the `find-riding.php` SQLi fix.
- **Travelling admins** are hard-blocked from outside Canada: temporary edit here, a Canadian VPN egress, or replace the geo rule with a Cloudflare Access policy.
- **ontariogreens.ca needs nothing**: its zone 301-deep-redirects to gpo.ca at the edge (path + query preserved) and its DNS never reaches the origin; the nginx server_name entry for it is vestigial. Already-handled-in-code items needing no edge rule: feeds, comments, generator tag, emoji scripts, `DISALLOW_FILE_MODS`, and the gpo-ca mu-plugin's anonymous-surface allowlists.
