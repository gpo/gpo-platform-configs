# secure.gpo.ca admin geo-restriction

A Cloudflare WAF custom rule that blocks admin and CiviCRM back-office routes on secure.gpo.ca from outside Canada, since all admins for the site are in Ontario, and country-level blocking is the level of precision available on the zone's current plan.

The rule itself lives in the shared ruleset `tf/infra/singletons/cloudflare_wordpress_admin_protection.tf`, owned by [gpo/gpo-platform-configs#217](https://github.com/gpo/gpo-platform-configs/pull/217), as an additional OR branch alongside the WordPress admin protection rule. Cloudflare allows only one `cloudflare_ruleset` per zone per phase (`http_request_firewall_custom`), and the zone's Free plan caps custom rules at five, all of which are in use, so this geo rule shares the existing rule slot rather than adding a new one. This PR only carries the DNS change that puts staging.secure.gpo.ca behind the proxy, and this documentation.

## What is blocked

On the in-scope hostname(s), requests matching any of the following paths are blocked unless the request's `ip.src.country` is `CA`:

- `/admin*`
- `/user/login` (exact match)
- `/civicrm/admin*`
- `/civicrm/a/*` (CiviCRM's Angular-based back office)

## Paths that must stay open

The rule is deliberately narrow. It does not touch, and must never be extended to cover:

- `/civicrm/contribute/transact` and `/civicrm/payment/ipn` — the donation form and PayPal/iATS payment IPN callbacks. Payment processors call these from their own IP ranges, not from Canada.
- `/civicrm/extern` — external integration endpoints.
- `/civicrm/mailing/*` — CiviMail open/click tracking links, which recipients click from anywhere.
- `/civicrm/ajax` — used by the public donation forms client-side.

Blocking any of these would break donations or mailing tracking for donors outside Canada.

## Plan-tier caveat: country-level, not Ontario-level

`ip.src.subdivision_1_iso_code` (province/state-level geolocation, which would let the rule target Ontario specifically) requires a Cloudflare Business or Enterprise plan. The zone is confirmed to be on the Free plan, so the rule uses `ip.src.country ne "CA"` instead: it blocks non-Canadian traffic but cannot distinguish Ontario from other provinces.

Tightening this to Ontario specifically is a future upgrade, gated on either moving the zone to a Business/Enterprise plan or finding an equivalent geolocation source available on Free.

## Staged rollout

`tf/infra/singletons/` has no stage tier of its own, so hostname scoping is used to stage this rollout instead:

1. **This PR**: the `staging_secure_gpo_ca` DNS record is switched to proxied (`proxied = true`, `ttl = 1`) so Cloudflare can enforce WAF rules at the edge for `staging.secure.gpo.ca`. The geo rule in PR #217 scopes itself to this hostname via its own `secure_admin_geo_hosts = ["staging.secure.gpo.ca"]` local, kept independent of the WordPress rule's host list so this rollout can proceed on its own schedule.
2. Verify on staging (see below).
3. **Follow-up PR**: append `"secure.gpo.ca"` to `secure_admin_geo_hosts` in the shared ruleset file to extend the rule to production.

## Verification steps

After the plan is applied to staging:

1. Confirm `https://staging.secure.gpo.ca` still loads normally. Proxying requires the staging origin's TLS certificate to satisfy the zone's SSL/TLS mode; if the origin only holds a certificate for a different name, enabling the proxy can break TLS for this hostname, so check this first.
2. From a non-Canadian source (e.g. a VPN endpoint, or Cloudflare's rule testing tools), confirm `/admin`, `/user/login`, `/civicrm/admin`, and `/civicrm/a/*` return a block response.
3. Confirm a donation page (e.g. `/civicrm/contribute/transact`) is still reachable from a non-Canadian source.

## Origin lockdown status

prod1 (the production origin) is already locked down to Cloudflare's IP ranges via iptables and ipsets (`/etc/ipset`, refreshed nightly), so edge rules on secure.gpo.ca cannot be bypassed by hitting prod1 directly. An earlier version of this document claimed the origin was open to all IPs; that was based on an incomplete, ufw-only view and was incorrect for prod1.

The open item is the staging origin, 137.184.128.54: its iptables/ipset lockdown status has not yet been verified. Until it is confirmed to match prod1's configuration, treat staging as potentially reachable by direct IP, bypassing this WAF rule.
