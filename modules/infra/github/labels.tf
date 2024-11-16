locals {
  colors = {
    repo_specific_color   = "0e8a16"
    who_should_work_on_it = "fbca04"
    type_coding           = "a2eeef"
    type_other            = "0366d6"
    ticket_dismissed      = "ffffff"
  }

  # repos wich get the standard set of issue labels
  repos_to_label = [
    github_repository.secure_gpo_ca.name,
    github_repository.gpo_ca.name,
    github_repository.readme.name,
    github_repository.gpo_platform_configs.name,
    github_repository.gpo_it.name
  ]
}

resource "github_issue_label" "epic" {
  for_each    = toset(local.repos_to_label)
  repository  = each.value
  name        = "Epic"
  description = "A large project that needs to be broken into parts"
  color       = "5319E7"
}

resource "github_issue_label" "enhancement" {
  for_each    = toset(local.repos_to_label)
  repository  = each.value
  name        = "enhancement"
  description = "New feature or request"
  color       = local.colors.type_coding
}

resource "github_issue_label" "performance" {
  for_each    = toset(local.repos_to_label)
  repository  = each.value
  name        = "performance"
  description = "Improves performance of the site"
  color       = local.colors.type_coding
}

resource "github_issue_label" "bug" {
  for_each    = toset(local.repos_to_label)
  repository  = each.value
  name        = "bug"
  description = "Something isn't working"
  color       = "d73a4a"
}

resource "github_issue_label" "documentation" {
  for_each    = toset(local.repos_to_label)
  repository  = each.value
  name        = "documentation"
  description = "Improvements or additions to documentation"
  color       = local.colors.type_other
}

resource "github_issue_label" "question" {
  for_each    = toset(local.repos_to_label)
  repository  = each.value
  name        = "question"
  description = "Further information is requested"
  color       = local.colors.type_other
}

resource "github_issue_label" "invalid" {
  for_each    = toset(local.repos_to_label)
  repository  = each.value
  name        = "invalid"
  description = "This doesn't seem right"
  color       = local.colors.ticket_dismissed
}

resource "github_issue_label" "wontfix" {
  for_each    = toset(local.repos_to_label)
  repository  = each.value
  name        = "wontfix"
  description = "This will not be worked on"
  color       = local.colors.ticket_dismissed
}

resource "github_issue_label" "duplicate" {
  for_each    = toset(local.repos_to_label)
  repository  = each.value
  name        = "duplicate"
  description = "This issue or pull request already exists"
  color       = local.colors.ticket_dismissed
}

resource "github_issue_label" "help_wanted" {
  for_each    = toset(local.repos_to_label)
  repository  = each.value
  name        = "help wanted"
  description = "Extra attention is needed"
  color       = local.colors.who_should_work_on_it
}

resource "github_issue_label" "good_first_issue" {
  for_each    = toset(local.repos_to_label)
  repository  = each.value
  name        = "good first issue"
  description = "Good for newcomers"
  color       = local.colors.who_should_work_on_it
}

resource "github_issue_label" "volunteer" {
  for_each    = toset(local.repos_to_label)
  repository  = each.value
  name        = "volunteer"
  description = "Good issue for a volunteer"
  color       = local.colors.who_should_work_on_it
}
