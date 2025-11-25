/*
rob - commenting this out until i figure out what this bucket is actually for
module "drupal" {
  source      = "../../modules/app/drupal"
  environment = local.environment
}*/

module "legacy_logging" {
  source = "../../modules/app/legacy_logging"
}

module "bi_dashboards" {
  source         = "../../modules/app/bi_dashboards"
  mysql_password = data.sops_file.environment_secrets.data["database_pass"]
  mysql_username = data.sops_file.environment_secrets.data["database_user"]
  mysql_host     = data.sops_file.environment_secrets.data["database_host"]
  gcp_project    = data.sops_file.environment_secrets.data["gcp_bi_project_id"]
  gcp_region     = "northamerica-northeast2"
}

module "grassroots" {
  source          = "../../modules/app/grassroots"
  cloudflare_zone = data.terraform_remote_state.infra.outputs.cloudflare_zone_gpo_tools
  environment     = local.environment

  providers = {
    google = google.gpo_eng
  }
}
