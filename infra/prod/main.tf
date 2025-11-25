module "gke" {
  source             = "../../modules/infra/gcp/gke"
  name               = local.name
  environment        = local.environment
  location           = local.zone_toronto
  cloudflare_zone_id = data.terraform_remote_state.bootstrap.outputs.cloudflare_zone_id
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
