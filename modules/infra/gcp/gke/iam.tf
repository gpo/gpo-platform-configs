resource "google_project_iam_member" "main" {
  project = data.google_client_config.current.project
  role    = "roles/artifactregistry.reader"
  member  = google_service_account.main.member
}
