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

resource "github_actions_secret" "SSH_HOST_STAGE" {
  repository =   "secure.gpo.ca"
  secret_name      = "SSH_HOST_STAGE"
  plaintext_value = var.secure_gpo_ca_stage_secret_ssh_host
}

resource "github_actions_secret" "SSH_HOST_PROD" {
  repository =   "secure.gpo.ca"
  secret_name      = "SSH_HOST_PROD"
  plaintext_value = var.secure_gpo_ca_prod_secret_ssh_host
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

resource "github_issue_labels" "secure_gpo_ca" {
  repository = "secure.gpo.ca"

  label {
    name        = "Drupal"
    description = "A change related to Drupal"
    color       = "0678be"
  }

  label {
    color       = "0075ca"
    description = "Improvements or additions to documentation"
    name        = "documentation"
  }

  label {
    color       = "008672"
    description = "Extra attention is needed"
    name        = "help wanted"
  }

  label {
    color       = "7057ff"
    description = "Good for newcomers"
    name        = "good first issue"
  }

  label {
    color       = "a2eeef"
    description = "New feature or request"
    name        = "enhancement"
  }

  label {
    color       = "cfd3d7"
    description = "This issue or pull request already exists"
    name        = "duplicate"
  }

  label {
    color       = "d73a4a"
    description = "Something isn't working"
    name        = "bug"
  }

  label {
    color       = "d876e3"
    description = "Further information is requested"
    name        = "question"
  }

  label {
    color       = "e4e669"
    description = "This doesn't seem right"
    name        = "invalid"
  }

  label {
    color       = "ffffff"
    description = "This will not be worked on"
    name        = "wontfix"
  }
}
