module "iam_users" {
  source          = "../modules/bootstrap/iam_users"
  iam_admin_users = local.iam_admin_users
  iam_eks_users   = local.iam_eks_users
}
