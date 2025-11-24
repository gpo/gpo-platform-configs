resource "google_artifact_registry_repository" "main" {
  location      = "northamerica-northeast2" # toronto
  repository_id = "gpo"
  description   = "repo for gpo containers"
  format        = "DOCKER"
}
