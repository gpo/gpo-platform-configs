output "hostname" {
  value       = cloudflare_record.argocd.name
  description = "The full hostname at which argocd can be reached."
}

output "service_account" {
  value = {
    email = google_service_account.main.email
    id    = google_service_account.main.id
  }
  description = "The GCP service account for ArgoCD."
}
