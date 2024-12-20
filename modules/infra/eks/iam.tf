# --------------------------------------------
#
# these resources are for the cluster itself

resource "aws_iam_role" "cluster" {
  name = "${var.name}-${var.environment}"
  # TODO iam policy document resource
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster" {
  # use canned EKS cluster policy
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

# --------------------------------------------
#
# these resources are for the users of the cluster

resource "aws_eks_access_entry" "admin" {
  for_each      = toset(var.admin_user_arns)
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = each.value
}

resource "aws_eks_access_policy_association" "example" {
  for_each      = toset(var.admin_user_arns)
  cluster_name  = aws_eks_cluster.main.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
  principal_arn = each.value

  access_scope {
    type = "cluster"
  }
}
