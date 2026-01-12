module "sops" {
  source      = "../../modules/bootstrap/sops"
  environment = local.environment
  providers = {
    google = google.bootstrap
  }
}

module "gcp_iam_devs" {
  for_each = toset(local.dev_users)
  source   = "../../modules/bootstrap/gcp_iam_devs_stage"
  project  = google_project.gpo_eng.project_id
  user     = each.value
}

module "apis" {
  source  = "../../modules/bootstrap/apis"
  project = google_project.gpo_eng.project_id
}
