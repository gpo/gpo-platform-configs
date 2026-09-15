resource "google_storage_bucket" "main" {
  name     = "gpo-canopy-${var.environment}"
  location = var.region

  public_access_prevention    = "enforced"
  uniform_bucket_level_access = false
}
