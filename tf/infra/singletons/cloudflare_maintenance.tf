# Maintenance page, on standby — no domains currently attached.
#
# A single static Cloudflare Pages project serves the maintenance message for
# every domain attached to it.

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

# To put a site into maintenance: add a cloudflare_pages_domain for the host
# and point its DNS record at cloudflare_pages_project.maintenance.subdomain
# (proxied CNAME). Revert both to bring the site back.
