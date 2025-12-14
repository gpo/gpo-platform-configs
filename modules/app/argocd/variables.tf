variable "ingress_ip_address" {
  type        = string
  description = "The GKE Ingress IP."
}

variable "cloudflare_zone" {
  type        = object({ id = string, zone = string })
  description = "The cloudflare zone on which to create DNS records."
}

variable "kms_key_id" {
  type        = string
  description = "The ID of the KMS key ArgoCD will use to decrypte YAMLs before applying them."
}
