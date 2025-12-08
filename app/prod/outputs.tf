output "legacy_logging" {
  description = "access key id and secret access key for the legacy logging IAM user"
  sensitive   = true
  value       = module.legacy_logging.access_key
}

output "grassroots" {
  description = "All outputs from the grassroots module."
  sensitive   = true
  value = {
    configmap = {
      GOOGLE_AUTH_CALLBACK_URL = "https://${module.grassroots.hostname}/api/auth/google/callback"
      GOOGLE_CLIENT_ID         = module.grassroots.oauth_client.id
      VITE_BACKEND_HOST        = "https://${module.grassroots.hostname}/api"
      VITE_FRONTEND_HOST       = "https://${module.grassroots.hostname}"
      WEBHOOK_HOST             = "https://${module.grassroots.hostname}"
    }
    secret = {
      GOOGLE_CLIENT_SECRET = module.grassroots.oauth_client.secret
    }
  }
}

output "superset" {
  description = "All outputs from the superset module."
  value = {
    httproute = {
      hostname = module.superset.hostname
    }
    values = {
      image_repository_uri = data.terraform_remote_state.infra.outputs.image_repository_uri
    }
  }
}
