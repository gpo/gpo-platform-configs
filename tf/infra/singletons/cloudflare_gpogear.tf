# gpogear.ca — zone registration; DNS records to follow once nameservers cut over

resource "cloudflare_zone" "gpogear_ca" {
  account_id = data.sops_file.secrets.data["cloudflare_account_id"]
  zone       = "gpogear.ca"
}

module "gpogear_ca_no_email" {
  source  = "../../modules/infra/no_email_dns"
  zone_id = cloudflare_zone.gpogear_ca.id
  domain  = "gpogear.ca"
}
