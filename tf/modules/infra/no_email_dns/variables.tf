variable "zone_id" {
  description = "Cloudflare zone ID the records belong to"
  type        = string
}

variable "domain" {
  description = "Full apex domain, e.g. \"example.ca\""
  type        = string
}
