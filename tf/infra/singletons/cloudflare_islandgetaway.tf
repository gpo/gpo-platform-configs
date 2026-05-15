# islandgetaway.ca — static site deployed via Cloudflare Pages
# GitHub repo: gpo/islandgetaway (branch: main)

resource "cloudflare_zone" "islandgetaway_ca" {
  account_id = data.sops_file.secrets.data["cloudflare_account_id"]
  zone       = "islandgetaway.ca"
}

resource "cloudflare_pages_project" "islandgetaway" {
  account_id        = data.sops_file.secrets.data["cloudflare_account_id"]
  name              = "islandgetaway-ca"
  production_branch = "main"

  source {
    type = "github"
    config {
      owner                         = "gpo"
      repo_name                     = "islandgetaway"
      production_branch             = "main"
      pr_comments_enabled           = true
      deployments_enabled           = true
      production_deployment_enabled = true
      preview_deployment_setting    = "all"
    }
  }

  build_config {
    build_command   = ""
    destination_dir = "/"
  }
}

resource "cloudflare_record" "islandgetaway_ca" {
  zone_id = cloudflare_zone.islandgetaway_ca.id
  name    = "islandgetaway.ca"
  content = cloudflare_pages_project.islandgetaway.subdomain
  type    = "CNAME"
  ttl     = 1
  proxied = true
}

# www CNAME so the hostname resolves at Cloudflare's edge before the redirect rule fires
resource "cloudflare_record" "www_islandgetaway_ca" {
  zone_id = cloudflare_zone.islandgetaway_ca.id
  name    = "www.islandgetaway.ca"
  content = cloudflare_pages_project.islandgetaway.subdomain
  type    = "CNAME"
  ttl     = 1
  proxied = true
}

resource "cloudflare_pages_domain" "islandgetaway_ca" {
  account_id   = data.sops_file.secrets.data["cloudflare_account_id"]
  project_name = cloudflare_pages_project.islandgetaway.name
  domain       = "islandgetaway.ca"
}

# 301 www → apex, preserving path and query string
resource "cloudflare_ruleset" "www_islandgetaway_ca_redirect" {
  zone_id = cloudflare_zone.islandgetaway_ca.id
  name    = "Redirect www to apex"
  kind    = "zone"
  phase   = "http_request_dynamic_redirect"

  rules {
    action      = "redirect"
    expression  = "(http.host eq \"www.islandgetaway.ca\")"
    description = "301 www.islandgetaway.ca -> islandgetaway.ca"
    enabled     = true

    action_parameters {
      from_value {
        status_code           = 301
        preserve_query_string = true

        target_url {
          expression = "concat(\"https://islandgetaway.ca\", http.request.uri.path)"
        }
      }
    }
  }
}
