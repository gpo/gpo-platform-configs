## secure.gpo.ca

resource "github_actions_secret" "gpo_ca_ssh_user" {
  repository      = "gpo.ca"
  secret_name     = "SSH_USER"
  plaintext_value = data.sops_file.secrets.data["ssh_user"]
}

resource "github_actions_secret" "gpo_ca_ssh_host_stage" {
  repository      = "gpo.ca"
  secret_name     = "SSH_HOST_STAGE"
  plaintext_value = data.sops_file.secrets.data["staging_ip_address"]
}

resource "github_actions_secret" "gpo_ca_ssh_host_prod1" {
  repository      = "gpo.ca"
  secret_name     = "SSH_HOST_PROD1"
  plaintext_value = data.sops_file.secrets.data["prod1_ip_address"]
}

resource "github_actions_secret" "gpo_ca_ssh_private_key" {
  repository      = "gpo.ca"
  secret_name     = "SSH_PRIVATE_KEY"
  plaintext_value = data.sops_file.secrets.data["ssh_private_key"]
}

resource "github_actions_secret" "gpo_ca_ssh_public_key" {
  repository      = "gpo.ca"
  secret_name     = "SSH_PUBLIC_KEY"
  plaintext_value = data.sops_file.secrets.data["ssh_public_key"]
}

## secure.gpo.ca

resource "github_actions_secret" "secure_gpo_ca_ssh_user" {
  repository      = "secure.gpo.ca"
  secret_name     = "SSH_USER"
  plaintext_value = data.sops_file.secrets.data["ssh_user"]
}

resource "github_actions_secret" "secure_gpo_ca_ssh_host_stage" {
  repository      = "secure.gpo.ca"
  secret_name     = "SSH_HOST_STAGE"
  plaintext_value = data.sops_file.secrets.data["staging_ip_address"]
}

resource "github_actions_secret" "secure_gpo_ca_ssh_host_prod" {
  repository      = "secure.gpo.ca"
  secret_name     = "SSH_HOST_PROD"
  plaintext_value = data.sops_file.secrets.data["prod1_ip_address"]
}

resource "github_actions_secret" "secure_gpo_ca_ssh_private_key" {
  repository      = "secure.gpo.ca"
  secret_name     = "SSH_PRIVATE_KEY"
  plaintext_value = data.sops_file.secrets.data["ssh_private_key"]
}

resource "github_actions_secret" "secure_gpo_ca_ssh_public_key" {
  repository      = "secure.gpo.ca"
  secret_name     = "SSH_PUBLIC_KEY"
  plaintext_value = data.sops_file.secrets.data["ssh_public_key"]
}
