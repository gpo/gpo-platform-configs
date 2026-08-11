output "cloudflare_zone_gpo_tools" {
  value = {
    id   = cloudflare_zone.gpo_tools.id,
    zone = cloudflare_zone.gpo_tools.zone
  }
}

output "gke_ingress_ip" {
  value = module.gke.ingress_ip
}

output "image_repository_uri" {
  value = module.gar.repository_uri
}

output "cloudflare_zone_gpogear" {
  value = {
    id   = cloudflare_zone.gpogear.id,
    zone = cloudflare_zone.gpogear.zone
  }
}

output "canopy_ingress_ip" {
  value = google_compute_global_address.canopy_ingress_ip.address
}
