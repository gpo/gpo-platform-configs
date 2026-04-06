module "sops" {
  source      = "../../modules/bootstrap/sops"
  environment = local.environment
  providers = {
    google = google.bootstrap
  }
}

module "apis" {
  source  = "../../modules/bootstrap/apis"
  project = google_project.gpo_eng.project_id
}
