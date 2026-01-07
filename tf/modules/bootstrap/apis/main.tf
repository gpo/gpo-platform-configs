resource "google_project_service" "secrets" {
  service            = "secretmanager.googleapis.com"
  disable_on_destroy = false # don't disable / renable the API on every tf destroy / apply
}
