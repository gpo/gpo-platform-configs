output "legacy_logging" {
  description = "access key id and secret access key for the legacy logging IAM user"
  sensitive   = true
  value       = module.legacy_logging.access_key
}

output "grassroots" {
  description = "All outputs required for kubernetes/grassroots."
  sensitive   = true
  value = {
    secret = {
      vite_backend_host  = "https://${module.grassroots.hostname}/api"
      vite_frontend_host = "https://${module.grassroots.hostname}"
      webhook_host       = "https://${module.grassroots.hostname}"
    }
    deployment = {
      image_repository_uri = data.terraform_remote_state.infra.outputs.image_repository_uri
    }
    httproute = {
      hostname = module.grassroots.hostname
    }
  }
}

output "superset" {
  description = "All outputs required for kubernetes/superset."
  value = {
    httproute = {
      hostname = module.superset.hostname
    }
    values = {
      image_repository_uri = data.terraform_remote_state.infra.outputs.image_repository_uri
    }
  }
}

output "gateway" {
  description = "All outputs required for kubernetes/gateway."
  value = {
    gateway = {
      hostnames = [
        { "name" = "grassroots", "hostname" = module.grassroots.hostname }
      ]
    }
  }
}
