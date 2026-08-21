output "cf_gsm_secret_id" {
  description = "ID of the secret in GSM where the cloudflare API token is stored."
  value       = local.secret_id
}
