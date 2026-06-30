output "gcp_project_gpo_data" {
  value = {
    id   = google_project.gpo_data.project_id
    name = google_project.gpo_data.name
  }
  description = "Project name and project ID for the GPO Data project"
}

output "gcp_project_gpo_eng" {
  value = {
    id   = google_project.gpo_eng.project_id
    name = google_project.gpo_eng.name
  }
  description = "Project name and project ID for the GPO Eng project"
}

output "gcp_project_bootstrap" {
  value = {
    id = "gpo-bootstrap-2"
  }
  description = "Project ID for the bootstrap project."
}
