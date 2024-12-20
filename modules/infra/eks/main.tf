# cluster, iam roles & policies, eks access entries, security groups, fargate config, cloudwatch log group

resource "aws_eks_cluster" "main" {

  name = "${var.name}-${var.environment}"

  # Ensure that IAM Role permissions are created before and deleted
  # after EKS Cluster handling. Otherwise, EKS will not be able to
  # properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.cluster,
  ]

  role_arn = aws_iam_role.cluster.arn

  vpc_config {
    subnet_ids = var.cluster_subnet_ids
  }

  access_config {
    # use the Cluster Access API for granting IAM users access to EKS (eg. kubectl)
    # https://www.eksworkshop.com/docs/security/cluster-access-management/understanding
    authentication_mode = "API"
  }

}
