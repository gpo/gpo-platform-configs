output "kms_key_id" {
  description = "ID of the GCP KMS key."
  value       = google_kms_crypto_key.sops.id
}
