variable "secure_gpo_ca_secret_ssh_user" {
  description = "SSH user for secure.gpo.ca"
  type        = string
}

variable "secure_gpo_ca_secret_ssh_host" {
  description = "SSH host for secure.gpo.ca"
  type        = string
}

variable "secure_gpo_ca_secret_ssh_private_key" {
    description = "SSH private key for secure.gpo.ca"
    type        = string
}

variable "secure_gpo_ca_secret_ssh_public_key" {
    description = "SSH public key for secure.gpo.ca"
    type        = string
}
