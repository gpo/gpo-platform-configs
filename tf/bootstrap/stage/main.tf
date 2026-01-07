module "iam_users" {
  source          = "../../modules/bootstrap/iam_users"
  iam_admin_users = local.iam_admin_users
  iam_eks_users   = local.iam_eks_users
  environment     = local.environment
}

module "state_bucket" {
  source            = "../../modules/bootstrap/state_bucket"
  state_bucket_name = "gpo-terraform-state"
}

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
  source = "../../modules/bootstrap/apis"
  providers = {
    google = google.bootstrap
  }
}
