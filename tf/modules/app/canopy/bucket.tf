resource "google_storage_bucket" "main" {
  name     = "gpo-canopy-${var.environment}"
  location = var.region
}
