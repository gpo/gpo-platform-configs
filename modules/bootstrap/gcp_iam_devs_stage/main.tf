# so they can push docker images
resource "google_project_iam_member" "registry_writer" {
  project = var.project
  role    = "roles/artifactregistry.writer"
  member  = "user:${var.user}"
}

# so they can use existing clusters but not delete / create them
resource "google_project_iam_member" "gke_dev" {
  project = var.project
  role    = "roles/container.developer"
  member  = "user:${var.user}"
}
