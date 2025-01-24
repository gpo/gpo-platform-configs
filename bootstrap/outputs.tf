output "admin_user_arns" {
  value       = module.iam_users.admin_user_arns
  description = "List of ARNs for all admin users."
}

output "eks_user_arns" {
  value       = module.iam_users.eks_user_arns
  description = "List of ARNs for all eks users."
}

output "user_creds" {
  value       = module.iam_users.user_creds
  sensitive   = true
  description = "Map of usernames to temporary initial passwords (must be changed on first login)."
}
