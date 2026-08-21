variable "environment" {
  type = string
  validation {
    condition     = contains(["prod", "stage"], var.environment)
    error_message = "Must be one of 'stage' or 'prod'."
  }
}

variable "database_tier" {
  # see: gcloud sql tiers list
  type        = string
  description = "CloudSQL DB Tier to deploy."
}

variable "database_edition" {
  type        = string
  description = "CloudSQL edition to deploy."
  validation {
    condition     = contains(["ENTERPRISE", "ENTERPRISE_PLUS"], var.database_edition)
    error_message = "database_edition must be either \"ENTERPRISE\" or \"ENTERPRISE_PLUS\"."
  }
}

variable "vpc_network_name" {
  type        = string
  description = "Name of the VPC in which to place the Canopy database."
}

variable "zone" {
  type        = string
  description = "GCP availability zone in which to place the Canopy DB."
}

variable "region" {
  type        = string
  description = "GCP region in which to place the Canopy DB."
}

variable "ingress_ip_address" {
  type        = string
  description = "The GKE Ingress IP."
}

variable "cloudflare_zone" {
  type        = object({ id = string, zone = string })
  description = "The cloudflare zone on which to create DNS records."
}
