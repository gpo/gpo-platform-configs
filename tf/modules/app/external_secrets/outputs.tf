output "service_account" {
  value = {
    email = google_service_account.main.email
    id    = google_service_account.main.id
  }
  description = "The GCP service account for External Secrets"
}
