output "hostname" {
  value       = cloudflare_dns_record.superset.name
  description = "The full hostname at which superset can be reached."
}
