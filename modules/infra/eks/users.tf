#########################################
#
# EKS access policy associations bind a canned K8s policy to a specific user and cluster.
# These are not regular IAM policies, these are strictly about what a user can do _within_ an EKS cluster.
#
# See here for a list of canned K8s policies: https://docs.aws.amazon.com/eks/latest/userguide/access-policy-permissions.html

#########################################
# admin users

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

#########################################
# non admin users

resource "aws_eks_access_entry" "user" {
  for_each      = toset(var.eks_user_arns)
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = each.value
}

resource "aws_eks_access_policy_association" "user" {
  for_each      = toset(var.eks_user_arns)
  cluster_name  = aws_eks_cluster.main.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
  principal_arn = each.value

  access_scope {
    type = "cluster"
  }
}
