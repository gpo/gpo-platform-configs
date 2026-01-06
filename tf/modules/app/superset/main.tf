# The DNS record for the Superset app.
resource "cloudflare_record" "superset" {
  zone_id = var.cloudflare_zone.id
  name    = "superset.${var.cloudflare_zone.zone}"
  content = var.ingress_ip_address
  type    = "A"
  ttl     = 300
  proxied = false
}
