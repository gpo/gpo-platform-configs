module "iam_users" {
  source          = "../../modules/infra/iam_users"
  iam_admin_users = local.iam_admin_users
}

module "eks" {
  source      = "../../modules/infra/eks"
  name        = local.project_name
  environment = local.environment
  cluster_subnet_ids = [module.vpc.public_subnet_id, module.vpc.private_subnet_id]
}

module "vpc" {
  source      = "../../modules/infra/vpc"
  name        = local.project_name
  environment = local.environment
}
