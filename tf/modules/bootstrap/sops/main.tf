resource "google_kms_key_ring" "sops" {
  name     = "sops-${var.environment}"
  location = "global"

  depends_on = [
    google_project_service.kms
  ]
}

resource "google_kms_crypto_key" "sops" {
  name     = "sops-${var.environment}"
  key_ring = google_kms_key_ring.sops.id

  depends_on = [
    google_project_service.kms
  ]

  lifecycle {
    prevent_destroy = true
  }
}
