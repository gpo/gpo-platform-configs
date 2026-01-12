output "gsm_secret_name" {
  description = "Name of the secret in google secret manager where the cloudflare API token is stored."
  value       = google_secret_manager_secret.cf_token.name
}
