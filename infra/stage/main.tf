module "iam_users" {
  source          = "../../modules/infra/iam_users"
  iam_admin_users = local.iam_admin_users
}

module "eks" {
  source = "../../modules/infra/eks"
}

module "vpc" {
  source = "../../modules/infra/vpc"
}
