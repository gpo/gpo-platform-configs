resource "github_repository" "secure_gpo_ca" {
  name                   = "secure-gpo-ca"
  description            = "Drupal and CiviCRM site running at secure.gpo.ca"
  visibility             = "private"
  allow_auto_merge       = true
  allow_merge_commit     = false
  allow_rebase_merge     = false
  delete_branch_on_merge = true
  has_downloads          = true
  has_issues             = true
  vulnerability_alerts   = true
  has_projects           = true
}

resource "github_branch_default" "secure_gpo_ca" {
  repository = github_repository.secure_gpo_ca.name
  branch     = "main"
}

#---

resource "github_repository" "gpo_ca" {
  name                   = "gpo-ca"
  visibility             = "private"
  allow_auto_merge       = true
  allow_merge_commit     = false
  allow_rebase_merge     = false
  delete_branch_on_merge = true
  has_downloads          = true
  has_issues             = true
  has_projects           = true
  vulnerability_alerts   = true
}

resource "github_branch_default" "gpo_ca" {
  repository = github_repository.gpo_ca.name
  branch     = "main"
}

#---

resource "github_repository" "readme" {
  name          = "readme"
  description   = "General information about how to access Technology at the GPO"
  visibility    = "private"
  has_downloads = true
  has_issues    = true
  has_projects  = true
}

resource "github_branch_default" "readme" {
  repository = github_repository.readme.name
  branch     = "main"
}

#---

resource "github_repository" "gpo_platform_configs" {
  name                   = "gpo-platform-configs"
  description            = "Infrastructure as Code for the GPO"
  visibility             = "public"
  has_projects           = true
  has_issues             = true
  has_downloads          = true
  allow_auto_merge       = true
  allow_merge_commit     = false
  allow_rebase_merge     = false
  delete_branch_on_merge = true
  vulnerability_alerts   = true
}

resource "github_branch_default" "gpo_platform_configs" {
  repository = github_repository.gpo_platform_configs.name
  branch     = "main"
}

#---

resource "github_repository" "gpo_it" {
  name          = "gpo-it"
  description   = "google workspace and future SAML config"
  visibility    = "private"
  has_downloads = true
  has_issues    = true
  has_projects  = true
}

resource "github_branch_default" "gpo_it" {
  repository = github_repository.gpo_it.name
  branch     = "main"
}

#---

resource "github_repository" "civicrm_api" {
  name          = "civicrm-api"
  description   = "JavaScript (and TypeScript) client for CiviCRM API v4"
  visibility    = "public"
  has_downloads = true
  has_projects  = true
}

resource "github_branch_default" "civicrm_api" {
  repository = github_repository.civicrm_api.name
  branch     = "main"
}

#---

resource "github_repository" "open_walk_sheets" {
  name                 = "open-walk-sheets"
  visibility           = "public"
  has_downloads        = true
  has_issues           = true
  has_projects         = true
  vulnerability_alerts = true
  has_wiki             = true
}

resource "github_branch_default" "open_walk_sheets" {
  repository = github_repository.open_walk_sheets.name
  branch     = "main"
}

#---

resource "github_repository" "dot_github" {
  name                 = ".github"
  visibility           = "public"
  has_downloads        = true
  has_issues           = true
  has_projects         = true
  has_wiki             = true
  vulnerability_alerts = true
}

resource "github_branch_default" "dot_github" {
  repository = github_repository.dot_github.name
  branch     = "main"
}

#---

resource "github_repository" "migrate_bitbucket_to_github" {
  name                 = "migrate_bitbucket_to_github"
  description          = "Simple Script for migrating repos from bitbucket to github"
  visibility           = "public"
  has_downloads        = true
  has_issues           = true
  has_projects         = true
  has_wiki             = true
  vulnerability_alerts = true
}

resource "github_branch_default" "migrate_bitbucket_to_github" {
  repository = github_repository.migrate_bitbucket_to_github.name
  branch     = "main"
}

#---

resource "github_repository" "cdn_tax_receipts" {
  name          = "CDNTaxReceipts"
  visibility    = "public"
  has_downloads = true
  has_projects  = true
}
