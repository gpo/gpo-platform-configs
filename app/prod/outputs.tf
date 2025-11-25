output "legacy_logging" {
  description = "access key id and secret access key for the legacy logging IAM user"
  sensitive   = true
  value       = module.legacy_logging.access_key
}

output "grassroots" {
  description = "All outputs from the grassroots module."
  sensitive   = true
  value = {
    oauth_client = module.grassroots.oauth_client
  }
}
