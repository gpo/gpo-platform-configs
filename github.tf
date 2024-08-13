# requires authorized gh
provider "github" {
  owner = "gpo"
}

resource "github_actions_secret" "SSH_USER" {
  repository      = "secure.gpo.ca"
  secret_name     = "SSH_USER"
  plaintext_value = var.secure_gpo_ca_secret_ssh_user
}

resource "github_actions_secret" "SSH_HOST_STAGE" {
  repository      = "secure.gpo.ca"
  secret_name     = "SSH_HOST_STAGE"
  plaintext_value = var.secure_gpo_ca_stage_secret_ssh_host
}

resource "github_actions_secret" "SSH_HOST_PROD" {
  repository      = "secure.gpo.ca"
  secret_name     = "SSH_HOST_PROD"
  plaintext_value = var.secure_gpo_ca_prod_secret_ssh_host
}

resource "github_actions_secret" "SSH_PRIVATE_KEY" {
  repository      = "secure.gpo.ca"
  secret_name     = "SSH_PRIVATE_KEY"
  plaintext_value = var.secure_gpo_ca_secret_ssh_private_key
}

resource "github_actions_secret" "SSH_PUBLIC_KEY" {
  repository      = "secure.gpo.ca"
  secret_name     = "SSH_PUBLIC_KEY"
  plaintext_value = var.secure_gpo_ca_secret_ssh_public_key
}

module "default_github_labels_for_secure_gpo_ca" {
  source     = "./default_github_labels_module"
  repository = "secure.gpo.ca"
}

module "default_github_labels_for_gpo_ca" {
  source     = "./default_github_labels_module"
  repository = "gpo.ca"
}

module "default_github_labels_for_readme" {
  source     = "./default_github_labels_module"
  repository = "readme"
}

module "default_github_labels_for_gpo_platform_configs" {
  source     = "./default_github_labels_module"
  repository = "gpo-platform-configs"
}
