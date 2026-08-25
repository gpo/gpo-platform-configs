resource "google_project_service" "secrets" {
  service            = "secretmanager.googleapis.com"
  disable_on_destroy = false # don't disable / renable the API on every tf destroy / apply
  project            = var.project
}

resource "google_project_service" "cloudsql_admin" {
  service            = "sqladmin.googleapis.com"
  disable_on_destroy = false
  project            = var.project
}

resource "google_project_service" "service_networking" {
  service            = "servicenetworking.googleapis.com"
  disable_on_destroy = false
  project            = var.project
}
