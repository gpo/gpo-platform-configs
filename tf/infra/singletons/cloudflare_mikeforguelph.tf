# mikeforguelph.ca: Guelph campaign site hosted by Ethical Host, mail on Google Workspace.
# guelphgreens.ca forwards here.

resource "cloudflare_zone" "mikeforguelph_ca" {
  account_id = data.sops_file.secrets.data["cloudflare_account_id"]
  zone       = "mikeforguelph.ca"
}

locals {
  mikeforguelph_ca_origin_ip = "172.86.185.90" # Ethical Host
}

# DNS-only: Ethical Host terminates TLS with its own certificate, and proxying
# would put Cloudflare's SSL mode between it and the origin.
resource "cloudflare_record" "mikeforguelph_ca" {
  zone_id = cloudflare_zone.mikeforguelph_ca.id
  name    = "mikeforguelph.ca"
  content = local.mikeforguelph_ca_origin_ip
  type    = "A"
  ttl     = 300
}

resource "cloudflare_record" "www_mikeforguelph_ca" {
  zone_id = cloudflare_zone.mikeforguelph_ca.id
  name    = "www.mikeforguelph.ca"
  content = local.mikeforguelph_ca_origin_ip
  type    = "A"
  ttl     = 300
}

resource "cloudflare_record" "mx_mikeforguelph_ca" {
  for_each = {
    "aspmx.l.google.com"      = 1
    "alt1.aspmx.l.google.com" = 5
    "alt2.aspmx.l.google.com" = 5
    "alt3.aspmx.l.google.com" = 10
    "alt4.aspmx.l.google.com" = 10
  }

  zone_id  = cloudflare_zone.mikeforguelph_ca.id
  name     = "mikeforguelph.ca"
  content  = each.key
  priority = each.value
  type     = "MX"
  ttl      = 300
}

resource "cloudflare_record" "spf_mikeforguelph_ca" {
  zone_id = cloudflare_zone.mikeforguelph_ca.id
  name    = "mikeforguelph.ca"
  content = "v=spf1 include:_spf.google.com ~all"
  type    = "TXT"
  ttl     = 300
}

resource "cloudflare_record" "google_site_verification_mikeforguelph_ca" {
  zone_id = cloudflare_zone.mikeforguelph_ca.id
  name    = "mikeforguelph.ca"
  content = "google-site-verification=Xwfzc9jUaI4gI3oZTKEKQox_L7u41bgpDOgiDDctqV8"
  type    = "TXT"
  ttl     = 300
}

resource "cloudflare_record" "google_domainkey_mikeforguelph_ca" {
  zone_id = cloudflare_zone.mikeforguelph_ca.id
  name    = "google._domainkey.mikeforguelph.ca"
  content = "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAsVUFj+Yg7tCMIROPHZsa3bdlr+BftsGALkAEkDa1SnphcL/TTmiotfxfnphM4SX3nqreWqZVUIz7DXou0AnOVbd+qI37EU0DsxBXPuNnzk2np8nC27sEKKhYpHU9IxwdqnamZJBhoo6fz2ZrfRz/iaDcuZpwvuO7CsEVDIFHb5xi3NxnOdsFtxyCmvUA3ZO7hdfWMO8rPVG8Im17+5WWGfTXkqJQyvWzvGqeIw6FG+CJo4iEAmMBfWFZyZvyNliN3csE0jsgs0pQat/ef0T6Df+PMyPAO10aAy/5+Yz0WoLV9tnRinaAysTiTlC5ZMuW7PZ8orYPkCcqxvwF+AO6awIDAQAB"
  type    = "TXT"
  ttl     = 300
}
