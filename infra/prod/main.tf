module "vpc" {
  source      = "../../modules/infra/vpc"
  name        = local.project_name
  environment = local.environment
}

module "eks" {
  source                      = "../../modules/infra/eks"
  name                        = local.project_name
  environment                 = local.environment
  public_subnet_ids           = [module.vpc.public_subnet_id]
  private_active_subnet_ids   = [module.vpc.private_active_subnet_id]
  private_inactive_subnet_ids = [module.vpc.private_inactive_subnet_id]
  # TODO: uncomment this once we have bootstrap in the prod AWS account
  admin_user_arns        = [] #data.terraform_remote_state.bootstrap.outputs.admin_user_arns
  nodegroup_desired_size = local.nodegroup_desired_size
  nodegroup_min_size     = local.nodegroup_min_size
  nodegroup_max_size     = local.nodegroup_max_size
}
