# secure.gpo.ca admin geo-restriction

A Cloudflare WAF custom rule that blocks admin and CiviCRM back-office routes on secure.gpo.ca from outside Ontario, Canada, since all admins for the site are in Ontario.

## What is blocked

On the in-scope hostname(s), requests matching any of the following paths are blocked unless the request's `ip.src.country` is `CA` and `ip.src.subdivision_1_iso_code` is `ON`:

- `/admin*`
- `/user/login` (exact match)
- `/civicrm/admin*`
- `/civicrm/a/*` (CiviCRM's Angular-based back office)

## Paths that must stay open

The rule is deliberately narrow. It does not touch, and must never be extended to cover:

- `/civicrm/contribute/transact` and `/civicrm/payment/ipn` — the donation form and PayPal/iATS payment IPN callbacks. Payment processors call these from their own IP ranges, not from Ontario.
- `/civicrm/extern` — external integration endpoints.
- `/civicrm/mailing/*` — CiviMail open/click tracking links, which recipients click from anywhere.
- `/civicrm/ajax` — used by the public donation forms client-side.

Blocking any of these would break donations or mailing tracking for donors outside Ontario, which is most of them.

## Plan-tier caveat

`ip.src.subdivision_1_iso_code` (province/state-level geolocation) requires a Cloudflare Business or Enterprise plan. The zone's current plan tier has not been verified as of this change; it is likely on the Free tier, which does not support this field and caps custom rules at five per zone.

If the API rejects the rule because the field is unsupported, `tf/infra/singletons/cloudflare_secure_admin_protection.tf` includes a commented-out fallback expression that uses only `ip.src.country ne "CA"` (country-level blocking, not Ontario-specific). Swap to that fallback and re-apply, then revisit once the plan tier is confirmed or upgraded.

## Staged rollout

`tf/infra/singletons/` has no stage tier of its own, so hostname scoping is used to stage this rollout instead:

1. **This PR**: the rule applies only to `staging.secure.gpo.ca`. The `staging_secure_gpo_ca` DNS record is switched to proxied (`proxied = true`, `ttl = 1`) so Cloudflare can enforce the rule at the edge.
2. Verify on staging (see below).
3. **Follow-up PR**: append `"secure.gpo.ca"` to the `secure_admin_geo_hosts` local in `cloudflare_secure_admin_protection.tf` to extend the rule to production.

## Verification steps

After the plan is applied to staging:

1. Confirm `https://staging.secure.gpo.ca` still loads normally. Proxying requires the staging origin's TLS certificate to satisfy the zone's SSL/TLS mode; if the origin only holds a certificate for a different name, enabling the proxy can break TLS for this hostname, so check this first.
2. From a non-Ontario source (e.g. a VPN endpoint outside Ontario, or Cloudflare's rule testing tools), confirm `/admin`, `/user/login`, `/civicrm/admin`, and `/civicrm/a/*` return a block response.
3. Confirm a donation page (e.g. `/civicrm/contribute/transact`) is still reachable from a non-Ontario source.

## Known gap: origin is not locked down

The origin server currently accepts direct HTTP/HTTPS traffic on ports 80 and 443 from any IP address, not just from Cloudflare's edge IP ranges. Until the origin firewall is restricted to Cloudflare's IPs, this WAF rule (and any other edge-level rule on this zone) can be bypassed by connecting to the origin's IP directly. Origin lockdown is tracked as a separate piece of work.
