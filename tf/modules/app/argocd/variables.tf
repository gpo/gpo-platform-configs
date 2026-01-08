variable "ingress_ip_address" {
  type        = string
  description = "The GKE Ingress IP."
}

variable "cloudflare_zone" {
  type        = object({ id = string, zone = string })
  description = "The cloudflare zone on which to create DNS records."
}

variable "bootstrap_project" {
  type        = string
  description = "The project ID of the bootstrap project."
}
