# ontariogreens.ca — migrated from prior registrar/DNS host

resource "cloudflare_zone" "ontariogreens_ca" {
  account_id = data.sops_file.secrets.data["cloudflare_account_id"]
  zone       = "ontariogreens.ca"
}

resource "cloudflare_record" "ontariogreens_ca" {
  zone_id = cloudflare_zone.ontariogreens_ca.id
  name    = "ontariogreens.ca"
  content = "24.199.64.246"
  type    = "A"
  ttl     = 1
  proxied = true
}

resource "cloudflare_record" "www_ontariogreens_ca" {
  zone_id = cloudflare_zone.ontariogreens_ca.id
  name    = "www.ontariogreens.ca"
  content = "24.199.64.246"
  type    = "A"
  ttl     = 1
  proxied = true
}

resource "cloudflare_record" "staging_ontariogreens_ca" {
  zone_id = cloudflare_zone.ontariogreens_ca.id
  name    = "staging.ontariogreens.ca"
  content = "134.209.128.228"
  type    = "A"
  ttl     = 1
  proxied = true
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
