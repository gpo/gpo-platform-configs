variable "name" {
  type        = string
  description = "A base name for VPC resources."
}

variable "environment" {
  type = string
  validation {
    condition     = contains(["prod", "stage"], var.environment)
    error_message = "Must be one of 'stage' or 'prod'."
  }
}

variable "location" {
  type        = string
  description = "Geographical location for the cluster."
}

variable "cloudflare_zone_id" {
  type        = string
  description = "The ID of the Cloudflare zone used for DNS records that point to the cluster."
}
