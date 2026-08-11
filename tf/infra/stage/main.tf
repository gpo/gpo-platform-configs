module "gke" {
  source      = "../../modules/infra/gcp/gke"
  name        = local.name
  environment = local.environment
  location    = local.zone_toronto
  providers = {
    google = google.gpo_eng
  }
}

module "gar" {
  source = "../../modules/infra/gcp/gar"
  providers = {
    google = google.gpo_eng
  }
}

# dedicated ingress IP for the canopy Gateway - kept separate from
# module.gke's shared gke-ingress-ip so canopy's public riding/campaign
# traffic doesn't share a Gateway with internal tooling (gpotools).
resource "google_compute_global_address" "canopy_ingress_ip" {
  name         = "canopy-ingress-ip"
  address_type = "EXTERNAL"
  ip_version   = "IPV4"
  provider     = google.gpo_eng
  depends_on   = [module.gke]
}
