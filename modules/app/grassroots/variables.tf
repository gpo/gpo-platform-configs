variable "environment" {
  type = string
  validation {
    condition     = contains(["prod", "stage"], var.environment)
    error_message = "Must be one of 'stage' or 'prod'."
  }
}

variable "ingress_ip_address" {
  type        = string
  description = "The GKE Ingress IP."
}

variable "cloudflare_zone" {
  type        = object({ id = string, zone = string })
  description = "The cloudflare zone on which to create DNS records."
}
