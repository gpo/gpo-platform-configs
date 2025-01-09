resource "aws_eks_cluster" "main" {

  name = local.name

  # Ensure that IAM Role permissions are created before and deleted
  # after EKS Cluster handling. Otherwise, EKS will not be able to
  # properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.cluster,
    aws_iam_role_policy_attachment.cluster_block_storage,
    aws_iam_role_policy_attachment.cluster_compute,
    aws_iam_role_policy_attachment.cluster_lb,
    aws_iam_role_policy_attachment.cluster_networking
  ]

  role_arn = aws_iam_role.cluster.arn

  vpc_config {
    subnet_ids = concat(var.private_active_subnet_ids, var.private_inactive_subnet_ids, var.public_subnet_ids)
  }

  access_config {
    # use the Cluster Access API for granting IAM users access to EKS (eg. kubectl)
    # https://www.eksworkshop.com/docs/security/cluster-access-management/understanding
    authentication_mode = "API"
  }
}

data "aws_iam_policy_document" "cluster_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
    effect = "Allow"
    principals {
      type = "Service"
      # allow our EKS clusters to use this role
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "cluster" {
  name               = local.name
  assume_role_policy = data.aws_iam_policy_document.cluster_assume_role.json
}

# here we use canned EKS cluster policies to grant our cluster the ability
# to create worker nodes, load balancers, EBS volumes, etc.

resource "aws_iam_role_policy_attachment" "cluster" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster_compute" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSComputePolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster_block_storage" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSBlockStoragePolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster_lb" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSLoadBalancingPolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster_networking" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSNetworkingPolicy"
  role       = aws_iam_role.cluster.name
}
