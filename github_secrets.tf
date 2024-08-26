## secure.gpo.ca

resource "github_actions_secret" "gpo_ca_SSH_USER" {
  repository      = "gpo.ca"
  secret_name     = "SSH_USER"
  plaintext_value = var.ssh_user
}

resource "github_actions_secret" "gpo_ca_SSH_HOST_STAGE" {
  repository      = "gpo.ca"
  secret_name     = "SSH_HOST_STAGE"
  plaintext_value = var.staging_ip_address
}

resource "github_actions_secret" "gpo_ca_SSH_HOST_PROD2" {
  repository      = "gpo.ca"
  secret_name     = "SSH_HOST_PROD2"
  plaintext_value = var.prod2_ip_address
}

resource "github_actions_secret" "gpo_ca_SSH_HOST_PROD1" {
  repository      = "gpo.ca"
  secret_name     = "SSH_HOST_PROD1"
  plaintext_value = var.prod1_ip_address
}

resource "github_actions_secret" "gpo_ca_SSH_PRIVATE_KEY" {
  repository      = "gpo.ca"
  secret_name     = "SSH_PRIVATE_KEY"
  plaintext_value = var.ssh_private_key
}

resource "github_actions_secret" "gpo_ca_SSH_PUBLIC_KEY" {
  repository      = "gpo.ca"
  secret_name     = "SSH_PUBLIC_KEY"
  plaintext_value = var.ssh_public_key
}

## secure.gpo.ca

resource "github_actions_secret" "SSH_USER" {
  repository      = "secure.gpo.ca"
  secret_name     = "SSH_USER"
  plaintext_value = var.ssh_user
}

resource "github_actions_secret" "SSH_HOST_STAGE" {
  repository      = "secure.gpo.ca"
  secret_name     = "SSH_HOST_STAGE"
  plaintext_value = var.staging_ip_address
}

resource "github_actions_secret" "SSH_HOST_PROD" {
  repository      = "secure.gpo.ca"
  secret_name     = "SSH_HOST_PROD"
  plaintext_value = var.prod1_ip_address
}

resource "github_actions_secret" "SSH_PRIVATE_KEY" {
  repository      = "secure.gpo.ca"
  secret_name     = "SSH_PRIVATE_KEY"
  plaintext_value = var.ssh_private_key
}

resource "github_actions_secret" "SSH_PUBLIC_KEY" {
  repository      = "secure.gpo.ca"
  secret_name     = "SSH_PUBLIC_KEY"
  plaintext_value = var.ssh_public_key
}
