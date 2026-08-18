locals {
  hostname = "canopy.${var.cloudflare_zone.zone}"
}

resource "cloudflare_dns_record" "canopy" {
  zone_id = var.cloudflare_zone.id
  name    = local.hostname
  content = var.ingress_ip_address
  type    = "A"
  ttl     = 300
  proxied = false
}
