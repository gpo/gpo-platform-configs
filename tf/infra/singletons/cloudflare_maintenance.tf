# Maintenance page for shut-down sites — gpo.ca and secure.gpo.ca
#
# A single static Cloudflare Pages project serves the maintenance message for
# every domain attached to it. ontariogreens.ca needs no changes: its existing
# redirect ruleset already lands visitors on gpo.ca.

# ---------------------------------------------------------------------------
# GitHub repo holding the page content, managed entirely from Terraform
# ---------------------------------------------------------------------------
resource "github_repository" "maintenance" {
  name                   = "maintenance"
  description            = "Static maintenance page served by Cloudflare Pages"
  visibility             = "public"
  auto_init              = true
  allow_auto_merge       = true
  allow_merge_commit     = false
  allow_rebase_merge     = true
  delete_branch_on_merge = true
  has_issues             = true
  vulnerability_alerts   = true
}

resource "github_branch_default" "maintenance" {
  repository = github_repository.maintenance.name
  branch     = "main"
}

# Page content (index.html) lives in the gpo/maintenance repo and ships via
# PR: an org ruleset blocks direct pushes to main, so Terraform cannot manage
# the file itself.

# ---------------------------------------------------------------------------
# Cloudflare Pages project
# ---------------------------------------------------------------------------
resource "cloudflare_pages_project" "maintenance" {
  account_id        = data.sops_file.secrets.data["cloudflare_account_id"]
  name              = "gpo-maintenance"
  production_branch = "main"

  source {
    type = "github"
    config {
      owner                         = "gpo"
      repo_name                     = github_repository.maintenance.name
      production_branch             = "main"
      pr_comments_enabled           = false
      deployments_enabled           = true
      production_deployment_enabled = true
      preview_deployment_setting    = "none"
    }
  }

  build_config {
    build_command   = ""
    destination_dir = "/"
  }
}

# ---------------------------------------------------------------------------
# Custom domains — both hosts serve the same page
# ---------------------------------------------------------------------------
resource "cloudflare_pages_domain" "maintenance_gpo_ca" {
  account_id   = data.sops_file.secrets.data["cloudflare_account_id"]
  project_name = cloudflare_pages_project.maintenance.name
  domain       = "gpo.ca"
}

resource "cloudflare_pages_domain" "maintenance_secure_gpo_ca" {
  account_id   = data.sops_file.secrets.data["cloudflare_account_id"]
  project_name = cloudflare_pages_project.maintenance.name
  domain       = "secure.gpo.ca"
}
