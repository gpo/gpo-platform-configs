# April Fools 1997 campaign site — https://1997.gpo.ca
#
# Deployment checklist:
#   1. Ensure the Cloudflare Pages GitHub connection is authorised in the
#      Cloudflare dashboard (Settings → Integrations → GitHub) before first apply.
#   2. To activate the apex redirect on April 1:
#        Edit locals.tf → set april_fools_redirect_enabled = true, then tofu apply
#   3. To deactivate after the campaign:
#        Edit locals.tf → set april_fools_redirect_enabled = false, then tofu apply

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

# ---------------------------------------------------------------------------
# Redirect rule — gpo.ca/* → https://1997.gpo.ca (302, April 1 only)
#
# Toggle by editing locals.tf → april_fools_redirect_enabled, then tofu apply.
# ---------------------------------------------------------------------------
resource "cloudflare_ruleset" "april_fools_redirect" {
  count       = local.april_fools_redirect_enabled ? 1 : 0
  zone_id     = cloudflare_zone.gpo_ca.id
  name        = "April Fools Redirect"
  description = "Redirects gpo.ca home page to https://1997.gpo.ca (302). Managed by local.april_fools_redirect_enabled in locals.tf."
  kind        = "zone"
  phase       = "http_request_dynamic_redirect"

  rules {
    action = "redirect"
    action_parameters {
      from_value {
        status_code = 302
        target_url {
          value = "https://1997.gpo.ca"
        }
        preserve_query_string = true
      }
    }
    expression  = "(http.host eq \"gpo.ca\" and http.request.uri.path eq \"/\")"
    description = "Redirect gpo.ca home page to 1997.gpo.ca for April Fools"
    enabled     = true
  }
}
