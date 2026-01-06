resource "aws_eks_node_group" "main" {
  cluster_name           = aws_eks_cluster.main.name
  version                = aws_eks_cluster.main.version
  node_role_arn          = aws_iam_role.node.arn
  subnet_ids             = var.private_active_subnet_ids
  node_group_name_prefix = "${aws_eks_cluster.main.name}-main"

  scaling_config {
    desired_size = var.nodegroup_desired_size
    max_size     = var.nodegroup_max_size
    min_size     = var.nodegroup_min_size
  }

  # allow nodes to be added / removed without TF plan showing a difference
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

}

data "aws_iam_policy_document" "node_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]
    effect = "Allow"
    principals {
      type = "Service"
      # allow our EC2 instances to use this role
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "node" {
  name               = "${aws_eks_cluster.main.name}-worker-node"
  assume_role_policy = data.aws_iam_policy_document.node_assume_role.json
}

# allow worker nodes to connect to EKS clusters
resource "aws_iam_role_policy_attachment" "node_eks" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node.name
}

# allow CNI plugin to modify IP config of worker nodes
resource "aws_iam_role_policy_attachment" "node_cni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node.name
}

# allow worker nodes to pull containers from ECR
resource "aws_iam_role_policy_attachment" "node_ecr_pull" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
  role       = aws_iam_role.node.name
}
