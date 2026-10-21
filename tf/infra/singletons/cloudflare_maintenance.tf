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

resource "github_repository_file" "maintenance_index" {
  repository          = github_repository.maintenance.name
  branch              = github_branch_default.maintenance.branch
  file                = "index.html"
  commit_message      = "Maintenance page"
  overwrite_on_create = true

  content = <<-HTML
    <!doctype html>
    <html lang="en">
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <meta name="robots" content="noindex">
      <title>Down for maintenance</title>
      <style>
        body { font-family: system-ui, sans-serif; background: #f4f7f4; color: #1f2a1f;
               display: grid; place-items: center; min-height: 100vh; margin: 0; }
        main { max-width: 32rem; padding: 2rem; text-align: center; }
        h1 { font-size: 1.5rem; }
      </style>
    </head>
    <body>
      <main>
        <h1>We&rsquo;ll be back soon</h1>
        <p>This site is temporarily offline for maintenance. Thanks for your patience.</p>
      </main>
    </body>
    </html>
  HTML
}

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
