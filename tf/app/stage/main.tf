/*
rob - commenting this out until i figure out what this bucket is actually for
module "drupal" {
  source      = "../../modules/app/drupal"
  environment = local.environment
}*/

module "canopy" {
  source             = "../../modules/app/canopy"
  cloudflare_zone    = data.terraform_remote_state.infra.outputs.cloudflare_zone_gpo_gear
  environment        = local.environment
  database_tier      = local.canopy_db_tier
  database_edition   = local.canopy_db_edition
  region             = local.region_toronto
  zone               = local.zone_toronto
  vpc_network_name   = data.terraform_remote_state.infra.outputs.gke_vpc_network_name
  ingress_ip_address = data.terraform_remote_state.infra.outputs.gke_ingress_ip
  providers = {
    google = google.gpo_eng
  }
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
  bootstrap_project  = data.terraform_remote_state.bootstrap.outputs.gcp_project_bootstrap.id
  providers = {
    google = google.gpo_eng
  }
}

module "external_secrets" {
  source = "../../modules/app/external_secrets"
  providers = {
    google = google.gpo_eng
  }
  secrets = [
    module.cert_manager.cf_gsm_secret_id,
    module.canopy.db_gsm_secret_id
  ]
  depends_on = [
    module.cert_manager,
    module.canopy
  ]
}

module "cert_manager" {
  source      = "../../modules/app/cert_manager"
  environment = local.environment
  cloudflare_zones = [
    data.terraform_remote_state.infra.outputs.cloudflare_zone_gpo_tools,
    data.terraform_remote_state.infra.outputs.cloudflare_zone_gpo_gear
  ]

  cloudflare_account_id = data.sops_file.secrets.data["cloudflare_account_id"]
  providers = {
    google = google.gpo_eng
  }
}
