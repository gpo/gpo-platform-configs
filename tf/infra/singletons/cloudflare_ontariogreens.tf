# ontariogreens.ca — migrated from prior registrar/DNS host

resource "cloudflare_zone" "ontariogreens_ca" {
  account_id = data.sops_file.secrets.data["cloudflare_account_id"]
  zone       = "ontariogreens.ca"
}

# No real origin — apex and www just terminate at Cloudflare's edge so the
# redirect ruleset below can fire. 192.0.2.1 is a documentation-only address
# (RFC 5737); it's never dialed because proxied traffic never reaches origin.
resource "cloudflare_record" "ontariogreens_ca" {
  zone_id = cloudflare_zone.ontariogreens_ca.id
  name    = "ontariogreens.ca"
  content = "192.0.2.1"
  type    = "A"
  ttl     = 1
  proxied = true
}

resource "cloudflare_record" "www_ontariogreens_ca" {
  zone_id = cloudflare_zone.ontariogreens_ca.id
  name    = "www.ontariogreens.ca"
  content = "192.0.2.1"
  type    = "A"
  ttl     = 1
  proxied = true
}

# 301 apex and www -> gpo.ca, preserving path and query string
resource "cloudflare_ruleset" "ontariogreens_ca_redirect" {
  zone_id = cloudflare_zone.ontariogreens_ca.id
  name    = "Redirect to gpo.ca"
  kind    = "zone"
  phase   = "http_request_dynamic_redirect"

  rules {
    action      = "redirect"
    expression  = "(http.host eq \"ontariogreens.ca\") or (http.host eq \"www.ontariogreens.ca\")"
    description = "301 ontariogreens.ca / www.ontariogreens.ca -> gpo.ca"
    enabled     = true

    action_parameters {
      from_value {
        status_code           = 301
        preserve_query_string = true

        target_url {
          expression = "concat(\"https://gpo.ca\", http.request.uri.path)"
        }
      }
    }
  }
}

# DNS-only: points at another provider's CDN, so it shouldn't be double-proxied
resource "cloudflare_record" "files_ontariogreens_ca" {
  zone_id = cloudflare_zone.ontariogreens_ca.id
  name    = "files.ontariogreens.ca"
  content = "gpo-files.nyc3.cdn.digitaloceanspaces.com"
  type    = "CNAME"
  ttl     = 300
}

resource "cloudflare_record" "facebook_domain_verification_ontariogreens_ca" {
  zone_id = cloudflare_zone.ontariogreens_ca.id
  name    = "ontariogreens.ca"
  content = "facebook-domain-verification=4ltuf6o3yrf9cq4506sbpol8wt7mtn"
  type    = "TXT"
  ttl     = 300
}

module "ontariogreens_ca_no_email" {
  source  = "../../modules/infra/no_email_dns"
  zone_id = cloudflare_zone.ontariogreens_ca.id
  domain  = "ontariogreens.ca"
}
