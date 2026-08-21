output "cloudflare_zone_gpo_tools" {
  value = {
    id   = cloudflare_zone.gpo_tools.id,
    zone = cloudflare_zone.gpo_tools.zone
  }
}

output "cloudflare_zone_gpo_gear" {
  value = {
    id   = cloudflare_zone.gpo_gear.id,
    zone = cloudflare_zone.gpo_gear.zone
  }
}

output "gke_ingress_ip" {
  value = module.gke.ingress_ip
}

output "gke_vpc_network_name" {
  value = module.gke.vpc_network_name
}

output "image_repository_uri" {
  value = module.gar.repository_uri
}
