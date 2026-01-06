/*
rob - commenting this out until i figure out what this bucket is actually for
module "drupal" {
  source      = "../../modules/app/drupal"
  environment = local.environment
}*/

module "legacy_logging" {
  source = "../../modules/app/legacy_logging"
}

module "grassroots" {
  source             = "../../modules/app/grassroots"
  cloudflare_zone    = data.terraform_remote_state.infra.outputs.cloudflare_zone_gpo_tools
  environment        = local.environment
  ingress_ip_address = data.terraform_remote_state.infra.outputs.gke_ingress_ip

  providers = {
    google = google.gpo_eng
  }
}

module "superset" {
  source             = "../../modules/app/superset"
  cloudflare_zone    = data.terraform_remote_state.infra.outputs.cloudflare_zone_gpo_tools
  ingress_ip_address = data.terraform_remote_state.infra.outputs.gke_ingress_ip
}

module "argocd" {
  source             = "../../modules/app/argocd"
  cloudflare_zone    = data.terraform_remote_state.infra.outputs.cloudflare_zone_gpo_tools
  ingress_ip_address = data.terraform_remote_state.infra.outputs.gke_ingress_ip
  kms_key_id         = data.terraform_remote_state.bootstrap.outputs.sops.kms_key_id
  bootstrap_project  = data.terraform_remote_state.bootstrap.outputs.gcp_project_bootstrap.id
  providers = {
    google = google.gpo_eng
  }
}
