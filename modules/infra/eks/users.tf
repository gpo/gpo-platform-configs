resource "aws_eks_access_entry" "admin" {
  for_each      = toset(var.admin_user_arns)
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = each.value
}

resource "aws_eks_access_policy_association" "admin" {
  for_each      = toset(var.admin_user_arns)
  cluster_name  = aws_eks_cluster.main.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = each.value

  access_scope {
    type = "cluster"
  }
}
