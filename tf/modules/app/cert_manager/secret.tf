resource "google_secret_manager_secret" "cf_token" {
  secret_id = "cert-manager-cf-api-token"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "cf_token" {
  secret      = google_secret_manager_secret.cf_token.id
  secret_data = cloudflare_api_token.cert_manager.value
}
