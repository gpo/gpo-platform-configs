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
      preview_deployment_setting    = "none"
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

resource "cloudflare_pages_domain" "islandgetaway_ca" {
  account_id   = data.sops_file.secrets.data["cloudflare_account_id"]
  project_name = cloudflare_pages_project.islandgetaway.name
  domain       = "islandgetaway.ca"
}
