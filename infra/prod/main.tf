module "eks" {
  source = "../../modules/infra/eks"
}

module "vpc" {
  source = "../../modules/infra/vpc"
}
