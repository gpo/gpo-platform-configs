resource "aws_iam_user" "admin" {
  for_each = toset(var.iam_admin_users)
  name     = each.value
}

resource "aws_iam_group" "admin" {
  name = "admin"
}

data "aws_iam_policy" "admin" {
  arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_group_policy_attachment" "admin" {
  group      = aws_iam_group.admin.name
  policy_arn = data.aws_iam_policy.admin.arn
}

resource "aws_iam_group_membership" "admin" {
  name  = "admin"
  users = [for user in aws_iam_user.admin : user.name]
  group = aws_iam_group.admin.name
}
