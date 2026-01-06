output "cloudflare_zone_id" {
  value = {
    zone_id = cloudflare_zone.gpo_ca.id
  }
  description = "Cloudflare zone ID. Used by other TF infra layers that need to provision DNS records."
}
