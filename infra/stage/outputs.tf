output "cloudflare_zone_gpo_tools" {
  value = {
    id   = cloudflare_zone.gpo_tools.id,
    zone = cloudflare_zone.gpo_tools.zone
  }
}
