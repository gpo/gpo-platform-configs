terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

provider "github" {
  owner = "gpo"
}

resource "github_issue_labels" "labels" {
  repository = var.repository

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
