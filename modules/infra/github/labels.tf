terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

locals {
  colors = {
    repo_specific_color   = "0e8a16"
    who_should_work_on_it = "fbca04"
    type_coding           = "a2eeef"
    type_other            = "0366d6"
    ticket_dismissed      = "ffffff"
  }
}

# custom lables for repository specific lables
resource "github_issue_label" "custom_labels" {
  for_each = { for label in var.labels : label.name => label }

  repository  = var.repository
  name        = each.value.name
  description = each.value.description
  color       = coalesce(each.value.color, local.colors.repo_specific_color)
}

resource "github_issue_label" "epic" {
  repository  = var.repository
  name        = "Epic"
  description = "A large project that needs to be broken into parts"
  color       = "5319E7"
}

resource "github_issue_label" "enhancement" {
  repository  = var.repository
  name        = "enhancement"
  description = "New feature or request"
  color       = local.colors.type_coding
}

resource "github_issue_label" "performance" {
  repository  = var.repository
  name        = "performance"
  description = "Improves performance of the site"
  color       = local.colors.type_coding
}

resource "github_issue_label" "bug" {
  repository  = var.repository
  name        = "bug"
  description = "Something isn't working"
  color       = "d73a4a"
}

resource "github_issue_label" "documentation" {
  repository  = var.repository
  name        = "documentation"
  description = "Improvements or additions to documentation"
  color       = local.colors.type_other
}

resource "github_issue_label" "question" {
  repository  = var.repository
  name        = "question"
  description = "Further information is requested"
  color       = local.colors.type_other
}

resource "github_issue_label" "invalid" {
  repository  = var.repository
  name        = "invalid"
  description = "This doesn't seem right"
  color       = local.colors.ticket_dismissed
}

resource "github_issue_label" "wontfix" {
  repository  = var.repository
  name        = "wontfix"
  description = "This will not be worked on"
  color       = local.colors.ticket_dismissed
}

resource "github_issue_label" "duplicate" {
  repository  = var.repository
  name        = "duplicate"
  description = "This issue or pull request already exists"
  color       = local.colors.ticket_dismissed
}

resource "github_issue_label" "help_wanted" {
  repository  = var.repository
  name        = "help wanted"
  description = "Extra attention is needed"
  color       = local.colors.who_should_work_on_it
}

resource "github_issue_label" "good_first_issue" {
  repository  = var.repository
  name        = "good first issue"
  description = "Good for newcomers"
  color       = local.colors.who_should_work_on_it
}

resource "github_issue_label" "volunteer" {
  repository  = var.repository
  name        = "volunteer"
  description = "Good issue for a volunteer"
  color       = local.colors.who_should_work_on_it
}
