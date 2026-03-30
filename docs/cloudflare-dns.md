# Cloudflare DNS

Relevant stack: `tf/infra/singletons/`

---

## Zones managed

| Zone | Resource | Stack |
|---|---|---|
| `gpo.ca` | `cloudflare_zone.gpo_ca` | `infra/singletons` |
| `gpotools.ca` | `cloudflare_zone.gpo_tools` | `infra/prod` |
| `gpotoolsstage.ca` | `cloudflare_zone.gpo_tools` | `infra/stage` |

The `gpo.ca` zone is defined in `tf/infra/singletons/cloudflare_domains.tf` and is the **primary production domain**. Changes here affect live traffic immediately.

---

## Provider config

Cloudflare provider v4.48.0 is used in `infra/` and singletons. Auth via SOPS secrets:

```hcl
provider "cloudflare" {
  email   = "ianedington@gpo.ca"
  api_key = data.sops_file.secrets.data["cloudflare_api_key"]
}
```

Account ID is also sourced from SOPS:
```hcl
account_id = data.sops_file.secrets.data["cloudflare_account_id"]
```

---

## Adding a DNS record to gpo.ca

All `gpo.ca` records live in `tf/infra/singletons/cloudflare_domains.tf`.

**Naming convention:** `cloudflare_record.<subdomain>_gpo_ca`, replacing dots and leading digits with underscores. Examples:
- `1997.gpo.ca` → `cloudflare_record._1997_gpo_ca`
- `staging.gpo.ca` → `cloudflare_record.staging_gpo_ca`
- `s1._domainkey.gpo.ca` → `cloudflare_record.s1__domainkey_gpo_ca`

**Template for a proxied A record:**
```hcl
resource "cloudflare_record" "myapp_gpo_ca" {
  zone_id = cloudflare_zone.gpo_ca.id
  name    = "myapp.gpo.ca"   # always full FQDN
  content = "1.2.3.4"
  type    = "A"
  ttl     = 1                # must be 1 when proxied = true
  proxied = true
}
```

**Template for a non-proxied CNAME:**
```hcl
resource "cloudflare_record" "myapp_gpo_ca" {
  zone_id = cloudflare_zone.gpo_ca.id
  name    = "myapp.gpo.ca"
  content = "target.example.com"
  type    = "CNAME"
  ttl     = 300
}
```

**TTL rule:** `ttl = 1` when `proxied = true`. Use `ttl = 300` when not proxied.

---

## Adding a DNS record to gpotools.ca / gpotoolsstage.ca

These zones are output from `infra/prod` and `infra/stage` and consumed by the `app/` layer via remote state. App-layer modules receive the zone as a variable:

```hcl
variable "cloudflare_zone" {
  type = object({ id = string, zone = string })
}
```

DNS records for apps in the `app/` layer are created inside modules under `tf/modules/app/<module-name>/`. The zone object is passed in from `tf/app/{prod,stage}/main.tf`.

Example (from the `grassroots` module):
```hcl
resource "cloudflare_record" "grassroots" {
  zone_id = var.cloudflare_zone.id
  name    = "grassroots.${var.cloudflare_zone.zone}"
  content = var.ingress_ip_address
  type    = "A"
  ttl     = 1
  proxied = true
}
```

---

## Redirect rules

Redirect rules use `cloudflare_ruleset` with `phase = "http_request_dynamic_redirect"`. Use `count` driven by a local to toggle on/off without `-var` flags. See `tf/infra/singletons/cloudflare_april_fools.tf` for a working example.

```hcl
locals {
  my_redirect_enabled = false  # flip to true, then tofu apply
}

resource "cloudflare_ruleset" "my_redirect" {
  count       = local.my_redirect_enabled ? 1 : 0
  zone_id     = cloudflare_zone.gpo_ca.id
  name        = "My Redirect"
  kind        = "zone"
  phase       = "http_request_dynamic_redirect"

  rules {
    action = "redirect"
    action_parameters {
      from_value {
        status_code = 302
        target_url {
          value = "https://destination.example.com"
        }
        preserve_query_string = false
      }
    }
    expression  = "(http.host eq \"gpo.ca\")"
    description = "Redirect description"
    enabled     = true
  }
}
```

---

## Zone ID reference cheatsheet

| Where you're working | How to get the zone ID |
|---|---|
| `infra/singletons` | `cloudflare_zone.gpo_ca.id` |
| `infra/prod` | `cloudflare_zone.gpo_tools.id` |
| `infra/stage` | `cloudflare_zone.gpo_tools.id` |
| `app/{prod,stage}` or a module | `var.cloudflare_zone.id` (passed from remote state) |
