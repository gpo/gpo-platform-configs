# Cloudflare DNS

## Zones

| Zone | Resource | File |
|---|---|---|
| `gpo.ca` | `cloudflare_zone.gpo_ca` | `tf/infra/singletons/cloudflare_domains.tf` |
| `gpotools.ca` | `cloudflare_zone.gpo_tools` | `tf/infra/prod/cloudflare_zone.tf` |
| `gpotoolsstage.ca` | `cloudflare_zone.gpo_tools` | `tf/infra/stage/cloudflare_zone.tf` |
| `gpogear.ca` | `cloudflare_zone.gpogear_ca` | `tf/infra/singletons/cloudflare_gpogear.tf` |
| `islandgetaway.ca` | `cloudflare_zone.islandgetaway_ca` | `tf/infra/singletons/cloudflare_islandgetaway.tf` |
| `ontariogreens.ca` | `cloudflare_zone.ontariogreens_ca` | `tf/infra/singletons/cloudflare_ontariogreens.tf` |

`gpo.ca` is global/production — no staging equivalent.

## Conventions

- Resource names: `cloudflare_record.<subdomain>_gpo_ca` (dots and leading digits → underscores, e.g. `_1997_gpo_ca`, `s1__domainkey_gpo_ca`)
- `name` is always the full FQDN
- `ttl = 1` when `proxied = true`, `ttl = 300` otherwise
- Auth: `cloudflare_api_key` and `cloudflare_account_id` from SOPS (`tf/infra/singletons/secrets.tf`)

## Zone ID by context

| Where | Expression |
|---|---|
| `infra/singletons` | `cloudflare_zone.gpo_ca.id` |
| `infra/prod` or `infra/stage` | `cloudflare_zone.gpo_tools.id` |
| `app/` layer or modules | `var.cloudflare_zone.id` (passed via remote state) |

## Redirect rules

Use `cloudflare_ruleset` with `phase = "http_request_dynamic_redirect"` and a `locals {}` toggle. See `tf/infra/singletons/cloudflare_april_fools.tf` for a working example.

## Domains that don't send mail

Use the `tf/modules/infra/no_email_dns` module to add anti-spoofing records (SPF `-all`, a null wildcard DKIM, and a DMARC `reject` policy) for any zone that has no MX records:

```hcl
module "example_ca_no_email" {
  source  = "../../modules/infra/no_email_dns"
  zone_id = cloudflare_zone.example_ca.id
  domain  = "example.ca"
}
```

Skip it for `gpo.ca`, which sends real mail (Google Workspace, SendGrid, Brevo).
