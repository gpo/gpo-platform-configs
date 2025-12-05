resource "google_project_iam_member" "registry_reader" {
  project = data.google_client_config.current.project
  role    = "roles/artifactregistry.reader"
  member  = google_service_account.main.member
}

resource "google_project_iam_member" "node_svc_account" {
  project = data.google_client_config.current.project
  role    = "roles/container.defaultNodeServiceAccount"
  member  = google_service_account.main.member
}
