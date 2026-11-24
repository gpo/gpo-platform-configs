output "cloudflare_zone_id" {
  value = {
    zone_id = cloudflare_zone.gpo_ca.id
  }
  description = "Cloudflare zone ID. Used by other TF infra layers that need to provision DNS records."
}

output "mikeforguelph_ca_name_servers" {
  value       = cloudflare_zone.mikeforguelph_ca.name_servers
  description = "Cloudflare nameservers to set at the mikeforguelph.ca registrar (Namespro)."
}
