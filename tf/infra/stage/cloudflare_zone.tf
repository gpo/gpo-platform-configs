/* this must only ever be used for staging */
resource "cloudflare_zone" "gpo_tools" {
  account_id = data.sops_file.secrets.data["cloudflare_account_id"]
  zone       = "gpotoolsstage.ca"
}

module "gpo_tools_no_email" {
  source  = "../../modules/infra/no_email_dns"
  zone_id = cloudflare_zone.gpo_tools.id
  domain  = "gpotoolsstage.ca"
}

# canopy testing ground - deliberately not gpo.ca or islandgetaway.ca, see
# kubernetes/canopy for why. Stage only for now.
resource "cloudflare_zone" "gpogear" {
  account_id = data.sops_file.secrets.data["cloudflare_account_id"]
  zone       = "gpogear.ca"
}

module "gpogear_no_email" {
  source  = "../../modules/infra/no_email_dns"
  zone_id = cloudflare_zone.gpogear.id
  domain  = "gpogear.ca"
}
