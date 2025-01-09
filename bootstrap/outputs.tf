output "admin_user_arns" {
  value       = module.iam_users.admin_user_arns
  description = "List of ARNs for all admin users."
}
