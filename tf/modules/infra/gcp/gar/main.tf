resource "google_project_service" "artifact_registry" {
  service            = "artifactregistry.googleapis.com"
  disable_on_destroy = false # don't disable / renable the API on every tf destroy / apply
}

resource "google_artifact_registry_repository" "main" {
  location      = "northamerica-northeast2" # toronto
  repository_id = "gpo"
  description   = "repo for gpo containers"
  format        = "DOCKER"

  depends_on = [
    google_project_service.artifact_registry
  ]
}
