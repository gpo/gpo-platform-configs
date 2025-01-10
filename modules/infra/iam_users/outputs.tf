output "admin_user_arns" {
  value       = [for user in aws_iam_user.admin : user.arn]
  description = "List of ARNs for all admin users."
}
