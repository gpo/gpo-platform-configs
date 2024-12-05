provider "cloudflare" {
  email   = "ianedington@gpo.ca"
  api_key = var.cloudflare_api_key
}

resource "cloudflare_zone" "gpo_ca" {
  account_id = var.cloudflare_account_id
  zone       = "gpo.ca"
}

resource "cloudflare_record" "gpo_ca" {
  zone_id = cloudflare_zone.gpo_ca.id
  name    = "gpo.ca"
  content = "24.199.64.246"
  type    = "A"
  ttl     = 3600
}

resource "cloudflare_record" "secure_gpo_ca" {
  zone_id = cloudflare_zone.gpo_ca.id
  name    = "secure.gpo.ca"
  content = "192.124.249.179"
  type    = "A"
  ttl     = 3600
}

resource "cloudflare_record" "txt_gpo_ca" {
  zone_id = cloudflare_zone.gpo_ca.id
  name    = "gpo.ca"
  content = "v=spf1 ip4:168.245.17.225 include:_spf.google.com include:helpscoutemail.com ~all"
  type    = "TXT"
  ttl     = 3600
}
