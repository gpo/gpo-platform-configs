###############################################
# allow users to see everything if env == stage

data "aws_iam_policy" "ro" {
  count = local.grant_stage_access ? 1 : 0
  arn   = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_group_policy_attachment" "ro" {
  count      = local.grant_stage_access ? 1 : 0
  group      = aws_iam_group.eks.name
  policy_arn = data.aws_iam_policy.ro[0].arn
}

###############################################
# allow users to push to ECR repositories if env == stage

data "aws_iam_policy" "ecr_power_user" {
  count = local.grant_stage_access ? 1 : 0
  arn   = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_group_policy_attachment" "ecr_power_user" {
  count      = local.grant_stage_access ? 1 : 0
  group      = aws_iam_group.eks.name
  policy_arn = data.aws_iam_policy.ecr_power_user[0].arn
}

###############################################
# allow users to perform KMS decryption with any key if env == stage

data "aws_iam_policy_document" "kms_decrypt" {
  count = local.grant_stage_access ? 1 : 0
  statement {
    sid = "AllowKMSDecrypt"
    actions = [
      "kms:Decrypt"
    ]
    effect    = "Allow"
    resources = ["arn:aws:kms::${data.aws_caller_identity.main.account_id}:key/*"]
  }
}

resource "aws_iam_policy" "kms_decrypt" {
  count       = local.grant_stage_access ? 1 : 0
  description = "Allow IAM users to perform KMS decryption with any key."
  policy      = data.aws_iam_policy_document.kms_decrypt[0].json
}

resource "aws_iam_group_policy_attachment" "kms_decrypt" {
  count      = local.grant_stage_access ? 1 : 0
  group      = aws_iam_group.eks.name
  policy_arn = aws_iam_policy.kms_decrypt[0].arn
}
