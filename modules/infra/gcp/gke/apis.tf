resource "google_project_service" "compute" {
  service            = "compute.googleapis.com"
  disable_on_destroy = false # don't disable / renable the API on every tf destroy / apply
}

resource "google_project_service" "container" {
  service            = "container.googleapis.com"
  disable_on_destroy = false
}
