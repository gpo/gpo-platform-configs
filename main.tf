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
provider "github" {}

resource "github_actions_secret" "SSH_USER" {
  repository =  "gpo/secure.gpo.ca"
  secret_name      = "SSH_USER"
  plaintext_value = var.secure_gpo_ca_secret_ssh_user
}

resource "github_actions_secret" "SSH_HOST" {
  repository =   "gpo/secure.gpo.ca"
  secret_name      = "SSH_HOST"
  plaintext_value = var.secure_gpo_ca_secret_ssh_host
}
