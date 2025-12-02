output "hostname" {
  value       = cloudflare_record.argocd.name
  description = "The full hostname at which argocd can be reached."
}
