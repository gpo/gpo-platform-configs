output "legacy_logging" {
  description = "access key id and secret access key for the legacy logging IAM user"
  value       = module.legacy_logging.access_key
  sensitive   = true
}
