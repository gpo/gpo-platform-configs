locals {
  secret_id = "tax-receipts-session-secret"
}

resource "random_password" "session_secret" {
  length = 20
}

resource "google_secret_manager_secret" "session_secret" {
  secret_id = local.secret_id

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "session_secret" {
  secret      = google_secret_manager_secret.session_secret.id
  secret_data = random_password.session_secret.result
}
