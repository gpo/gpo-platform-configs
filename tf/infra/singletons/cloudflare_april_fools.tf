# April Fools 1997 campaign site — https://1997.gpo.ca
#
# Deployment checklist:
#   1. Ensure the Cloudflare Pages GitHub connection is authorised in the
#      Cloudflare dashboard (Settings → Integrations → GitHub) before first apply.

# ---------------------------------------------------------------------------
# Cloudflare Pages project — deploys github.com/gpo/1997 (branch: main)
# ---------------------------------------------------------------------------
resource "cloudflare_pages_project" "april_fools" {
  account_id        = data.sops_file.secrets.data["cloudflare_account_id"]
  name              = "1997-gpo-ca"
  production_branch = "main"

  source {
    type = "github"
    config {
      owner                         = "gpo"
      repo_name                     = "1997"
      production_branch             = "main"
      pr_comments_enabled           = true
      deployments_enabled           = true
      production_deployment_enabled = true
      preview_deployment_setting    = "none"
    }
  }

  build_config {
    # No build step — static files served directly from the repo root
    build_command   = ""
    destination_dir = "/"
  }
}

# ---------------------------------------------------------------------------
# DNS — CNAME 1997.gpo.ca → <project>.pages.dev
# ---------------------------------------------------------------------------
resource "cloudflare_record" "_1997_gpo_ca" {
  zone_id = cloudflare_zone.gpo_ca.id
  name    = "1997.gpo.ca"
  # subdomain is the computed <project>.pages.dev hostname
  content = cloudflare_pages_project.april_fools.subdomain
  type    = "CNAME"
  # TTL must be 1 when proxied == true
  ttl     = 1
  proxied = true
}

# ---------------------------------------------------------------------------
# Pages custom domain — attaches 1997.gpo.ca to the Pages project
# ---------------------------------------------------------------------------
resource "cloudflare_pages_domain" "april_fools_1997_gpo_ca" {
  account_id   = data.sops_file.secrets.data["cloudflare_account_id"]
  project_name = cloudflare_pages_project.april_fools.name
  domain       = "1997.gpo.ca"
}
