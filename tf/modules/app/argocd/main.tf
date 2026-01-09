resource "cloudflare_dns_record" "argocd" {
  zone_id = var.cloudflare_zone.id
  name    = "argocd.${var.cloudflare_zone.zone}"
  content = var.ingress_ip_address
  type    = "A"
  ttl     = 300
  proxied = false
}
