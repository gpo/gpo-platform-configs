terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

# Configure the GitHub Provider
# requires authorized gh
provider "github" {
  owner = "gpo"
}

resource "github_actions_secret" "SSH_USER" {
  repository =  "secure.gpo.ca"
  secret_name      = "SSH_USER"
  plaintext_value = var.secure_gpo_ca_secret_ssh_user
}

resource "github_actions_secret" "SSH_HOST" {
  repository =   "secure.gpo.ca"
  secret_name      = "SSH_HOST"
  plaintext_value = var.secure_gpo_ca_secret_ssh_host
}

resource "github_actions_secret" "SSH_PRIVATE_KEY" {
  repository       = "secure.gpo.ca"
  secret_name      = "SSH_PRIVATE_KEY"
  plaintext_value  = var.secure_gpo_ca_secret_ssh_private_key
}

resource "github_actions_secret" "SSH_PUBLIC_KEY" {
  repository       = "secure.gpo.ca"
  secret_name      = "SSH_PUBLIC_KEY"
  plaintext_value  = var.secure_gpo_ca_secret_ssh_public_key
}
