resource "github_repository" "secure_gpo_ca" {
  name         = "secure.gpo.ca"
  description  = "TBD"
  homepage_url = "https://secure.gpo.ca/"
  visibility   = "private"
}

resource "github_branch_default" "secure_gpo_ca" {
  repository = github_repository.secure_gpo_ca.name
  branch     = "main"
}

resource "github_issue_label" "civi_crm" {
  repository  = github_repository.secure_gpo_ca.name
  name        = "CiviCRM"
  description = "TBD"
  color       = locals.colors.repo_specific_color
}

resource "github_issue_label" "drupa" {
  repository  = github_repository.secure_gpo_ca.name
  name        = "Drupal"
  description = "TBD"
  color       = locals.colors.repo_specific_color
}

#---

resource "github_repository" "gpo_ca" {
  name         = "gpo.ca"
  description  = "TBD"
  homepage_url = "https://gpo.ca/"
  visibility   = "private"
}

resource "github_branch_default" "gpo_ca" {
  repository = github_repository.gpo_ca.name
  branch     = "main"
}

#---

resource "github_repository" "readme" {
  name         = "readme"
  description  = "TBD"
  homepage_url = "https://github.com/gpo/readme"
  visibility   = "private"
}

resource "github_branch_default" "secure_gpo_ca" {
  repository = github_repository.readme.name
  branch     = "main"
}

#---

resource "github_repository" "gpo_platform_configs" {
  name         = "gpo-platform-configs"
  description  = "Infrastructure as Code for the GPO"
  homepage_url = "https://github.com/gpo/gpo-platform-configs/"
  visibility   = "public"
}

resource "github_branch_default" "gpo_platform_configs" {
  repository = github_repository.gpo_platform_configs.name
  branch     = "main"
}

#---

resource "github_repository" "gpo_it" {
  name         = "gpo-it"
  description  = "TBD"
  homepage_url = "https://github.com/gpo/gpo-it"
  visibility   = "private"
}

resource "github_branch_default" "gpo_it" {
  repository = github_repository.gpo_it.name
  branch     = "main"
}

#---

resource "github_repository" "civicrm_api" {
  name        = "civicrm-api"
  description = "JavaScript (and TypeScript) client for CiviCRM API v4"
  visibility  = "public"
}

resource "github_branch_default" "civicrm_api" {
  repository = github_repository.civicrm_api.name
  branch     = "main"
}

#---

resource "github_repository" "open_walk_sheets" {
  name       = "open-walk-sheets"
  visibility = "public"
}

resource "github_branch_default" "open_walk_sheets" {
  repository = github_repository.open_walk_sheets.name
  branch     = "main"
}

#---

resource "github_repository" "dot_github" {
  name       = ".github"
  visibility = "public"
}

resource "github_branch_default" "gpo_it" {
  repository = github_repository.dot_github.name
  branch     = "main"
}

#---

resource "github_repository" "migrate_bitbucket_to_github" {
  name        = "migrate_bitbucket_to_github"
  description = "Simple Script for migrating repos from bitbucket to github "
  visibility  = "public"
}

resource "github_branch_default" "migrate_bitbucket_to_github" {
  repository = github_repository.migrate_bitbucket_to_github.name
  branch     = "main"
}

#---

resource "github_repository" "cdn_tax_receipts" {
  name       = "CDNTaxReceipts"
  visibility = "public"
}

resource "github_branch_default" "cdn_tax_receipts" {
  repository = github_repository.cdn_tax_receipts.name
  branch     = "main"
}
