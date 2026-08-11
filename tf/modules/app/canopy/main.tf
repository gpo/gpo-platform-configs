locals {
  wildcard_hostname = "*.${var.cloudflare_zone.zone}"
}

# wildcarded so every riding/campaign site tested against this zone routes
# through the canopy Gateway without a DNS change per site
resource "cloudflare_dns_record" "canopy_wildcard" {
  zone_id = var.cloudflare_zone.id
  name    = local.wildcard_hostname
  content = var.ingress_ip_address
  type    = "A"
  ttl     = 300
  proxied = false
}
