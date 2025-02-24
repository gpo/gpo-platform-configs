# make an iam user for each entry in the iam_eks_users list
resource "aws_iam_user" "eks" {
  for_each = toset(var.iam_eks_users)
  name     = each.value
}

# give each user a temporary password for logging into aws web console
resource "aws_iam_user_login_profile" "eks" {
  for_each                = toset([for user in aws_iam_user.eks : user.name])
  user                    = each.value
  password_reset_required = true
}

resource "aws_iam_group" "eks" {
  name = "eks"
}

# make each user a member of the EKS group
resource "aws_iam_group_membership" "eks" {
  name  = "eks"
  users = [for user in aws_iam_user.eks : user.name]
  group = aws_iam_group.eks.name
}

########################################
# allow users to see everything

data "aws_iam_policy" "ro" {
  arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_group_policy_attachment" "ro" {
  group      = aws_iam_group.eks.name
  policy_arn = data.aws_iam_policy.ro.arn
}


########################################
# allow users to push to ECR repositories

data "aws_iam_policy" "ecr_power_user" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_group_policy_attachment" "ecr_power_user" {
  group      = aws_iam_group.eks.name
  policy_arn = data.aws_iam_policy.ecr_power_user.arn
}

########################################
# allow users to manage their own accounts

data "aws_iam_policy_document" "manage_own_access" {

  statement {
    sid = "AllowManageOwnPasswords"
    actions = [
      "iam:ChangePassword",
      "iam:GetUser"
    ]
    effect    = "Allow"
    resources = ["arn:aws:iam::*:user/$${aws:username}"]
  }

  statement {
    sid = "AllowManageOwnAccessKeys"
    actions = [
      "iam:CreateAccessKey",
      "iam:DeleteAccessKey",
      "iam:ListAccessKeys",
      "iam:UpdateAccessKey",
      "iam:GetAccessKeyLastUsed"
    ]
    effect    = "Allow"
    resources = ["arn:aws:iam::*:user/$${aws:username}"]
  }

  statement {
    sid = "AllowManageOwnSSHPublicKeys"
    actions = [
      "iam:DeleteSSHPublicKey",
      "iam:GetSSHPublicKey",
      "iam:ListSSHPublicKeys",
      "iam:UpdateSSHPublicKey",
      "iam:UploadSSHPublicKey"
    ]
    effect    = "Allow"
    resources = ["arn:aws:iam::*:user/$${aws:username}"]
  }
}

resource "aws_iam_policy" "manage_own_access" {
  name        = "manage_own_access"
  description = "Allow IAM users to manage their own accounts."
  policy      = data.aws_iam_policy_document.manage_own_access.json
}

resource "aws_iam_group_policy_attachment" "manage_own_access" {
  group      = aws_iam_group.eks.name
  policy_arn = aws_iam_policy.manage_own_access.arn
}
