# gpo.ca variables

variable "prod1_ip_address" {
  description = "Prod1 server IP address"
  type        = string
  sensitive   = true
}
variable "prod2_ip_address" {
  description = "Prod2 server IP address"
  type        = string
  sensitive   = true
}
variable "staging_ip_address" {
  description = "staging server IP address"
  type        = string
  sensitive   = true
}

variable "ssh_user" {
  description = "SSH user for gpo.ca"
  type        = string
}

variable "ssh_private_key" {
  description = "SSH private key"
  type        = string
  sensitive   = true
}

variable "ssh_public_key" {
  description = "SSH public key"
  type        = string
}
