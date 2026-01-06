output "admin_user_arns" {
  value       = [for user in aws_iam_user.admin : user.arn]
  description = "List of ARNs for all admin users."
}

output "eks_user_arns" {
  value       = [for user in aws_iam_user.eks : user.arn]
  description = "List of ARNs for all EKS users."
}

output "user_creds" {
  value = merge({ for user in aws_iam_user_login_profile.eks : user.user => user.password },
  { for user in aws_iam_user_login_profile.admin : user.user => user.password })
  description = "Map of usernames to temporary initial passwords (must be changed on first login)."
}
