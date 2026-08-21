/* this must only ever be used for prod */
resource "cloudflare_zone" "gpo_tools" {
  account_id = data.sops_file.secrets.data["cloudflare_account_id"]
  zone       = "gpotools.ca"
}

module "gpo_tools_no_email" {
  source  = "../../modules/infra/no_email_dns"
  zone_id = cloudflare_zone.gpo_tools.id
  domain  = "gpotools.ca"
}
