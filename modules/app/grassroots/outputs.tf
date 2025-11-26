output "oauth_client" {
  value = {
    id     = google_iam_oauth_client.grassroots.oauth_client_id
    secret = google_iam_oauth_client_credential.grassroots.client_secret
  }
}

output "hostname" {
  value = cloudflare_record.grassroots.name
}
