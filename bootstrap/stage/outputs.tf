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

output "gcp_project_gpo_data" {
  value = {
    project_id = google_project.gpo_data.project_id
    name       = google_project.gpo_data.name
  }
  description = "Project name and project ID for the GPO Data project"
}

output "gcp_project_gpo_eng" {
  value = {
    project_id = google_project.gpo_eng.project_id
    name       = google_project.gpo_eng.name
  }
  description = "Project name and project ID for the GPO Eng project"
}
