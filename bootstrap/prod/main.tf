module "iam_users" {
  source          = "../../modules/bootstrap/iam_users"
  iam_admin_users = local.iam_admin_users
  iam_eks_users   = local.iam_eks_users
  environment     = local.environment
}

module "state_bucket" {
  source            = "../../modules/bootstrap/state_bucket"
  state_bucket_name = "gpo-terraform-state-${local.environment}"
}

module "sops" {
  source      = "../../modules/bootstrap/sops"
  environment = local.environment
}
