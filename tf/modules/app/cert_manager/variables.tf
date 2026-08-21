variable "cloudflare_zones" {
  description = "The CF zones cert mgr will solve DNS01 acme challenges on."
  type        = list(object({ id = string, zone = string }))
}

variable "cloudflare_account_id" {
  description = "The CF account ID the cert mgr API token will be granted access to."
  type        = string
}

variable "environment" {
  description = "The name of the environment (stage / prod)."
  type        = string
}
