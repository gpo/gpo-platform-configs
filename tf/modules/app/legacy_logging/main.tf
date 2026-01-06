# create the user
resource "aws_iam_user" "digital_ocean_monitoring" {
  name = "digital-ocean-monitoring"
}

resource "aws_iam_access_key" "digital_ocean_monitoring" {
  user = aws_iam_user.digital_ocean_monitoring.name
}

data "aws_iam_policy_document" "digital_ocean_monitoring" {
  statement {
    effect = "Allow"
    actions = [
      "cloudwatch:PutMetricData",
      "logs:PutLogEvents",
      "logs:PutRetentionPolicy",
      "logs:DescribeLogStreams",
      "logs:DescribeLogGroups",
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
    ]
    resources = ["*"]
  }
}

# create and attach a policy to the role which permits cloudwatch logging actions
resource "aws_iam_policy" "digital_ocean_monitoring" {
  name   = "digital-ocean-monitoring"
  policy = data.aws_iam_policy_document.digital_ocean_monitoring.json
}

resource "aws_iam_user_policy_attachment" "digital_ocean_monitoring" {
  user       = aws_iam_user.digital_ocean_monitoring.name
  policy_arn = aws_iam_policy.digital_ocean_monitoring.arn
}
