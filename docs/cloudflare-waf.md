# Cloudflare WAF / bot protection

## WordPress admin/login hardening (gpo.ca zone)

Resources: `tf/infra/singletons/cloudflare_wordpress_admin_protection.tf`

Admin/login endpoints on WordPress sites are constantly probed by automated
scanning and credential-stuffing traffic. Three layers protect them on the
`gpo.ca` zone, applied by path so they cover every WordPress install sharing
the zone (`gpo.ca`, `secure.gpo.ca`, and any future subdomain), not just one
site:

1. **Bot Fight Mode** (`cloudflare_bot_management.gpo_ca`) — zone-wide,
   available on every Cloudflare plan tier. Challenges traffic Cloudflare
   identifies as definitely automated.
2. **Rate limiting** (`cloudflare_ruleset.gpo_ca_wp_login_rate_limit`) —
   blocks a source IP for 10 minutes after 5 POSTs to `/wp-login.php` within
   60 seconds. Adjust via the `wp_login_rate_limit_*` locals.
3. **WAF custom rule** (`cloudflare_ruleset.gpo_ca_admin_route_protection`)
   — issues a managed challenge to any request matching `/wp-login.php`,
   `/xmlrpc.php`, or `/wp-admin/*`. `/wp-admin/admin-ajax.php` is
   deliberately excluded: plugins (contact forms, WooCommerce, etc.) call it
   from the public-facing, unauthenticated site, so challenging it would
   break normal visitor traffic.

### Open items

- **Plan tier.** Super Bot Fight Mode (`sbfm_*` fields and
  `optimize_wordpress` on `cloudflare_bot_management`) requires a Pro plan
  or above and isn't enabled here because the account's current tier hasn't
  been confirmed. If the zone is Pro+, add those fields to get
  WordPress-tuned bot scoring.
- **Geo-scoping to Canada.** `local.restrict_admin_routes_to_canada` in
  `cloudflare_wordpress_admin_protection.tf` adds a second WAF rule that
  issues a managed challenge (not a hard block) to non-CA traffic hitting
  admin routes, additive to the two layers above. It defaults to `false`.
  A challenge was chosen over an outright block so a travelling admin can
  still get through by solving it, standing in for a proper exception
  process. Before flipping this on:
  - Confirm this is acceptable as the exception mechanism, or design a
    dedicated one (e.g. a temporary IP allowlist rule, or a Cloudflare
    Access policy for admin routes instead of geo-matching).
  - Decide whether other zones on the account (see
    [cloudflare-dns.md](cloudflare-dns.md)) need the same treatment.
