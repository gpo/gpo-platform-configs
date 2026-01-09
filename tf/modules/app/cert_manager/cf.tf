/* cloudflare permissions are granted using big long guid looking strings 🤮
   we look them up here so we can grant them later */

data "cloudflare_api_token_permission_groups_list" "zone_read" {
  name      = "Zone Read"
  scope     = "com.cloudflare.api.account.zone"
  max_items = 1
}

data "cloudflare_api_token_permission_groups_list" "dns_write" {
  name      = "DNS Write"
  scope     = "com.cloudflare.api.account.zone"
  max_items = 1
}

locals {
  zone_read = data.cloudflare_api_token_permission_groups_list.zone_read.result[0].id
  dns_write = data.cloudflare_api_token_permission_groups_list.dns_write.result[0].id
}

resource "cloudflare_api_token" "cert_manager" {
  name   = "cert-manager.${var.environment}"
  status = "active"

  policies = [{
    effect = "allow"

    permission_groups = [
      { id = local.zone_read },
      { id = local.dns_write },
    ]

    # scope token to exactly one zone
    resources = jsonencode({
      "com.cloudflare.api.account.${var.cloudflare_account_id}" = {
        "com.cloudflare.api.account.zone.${var.cloudflare_zone.id}" = "*"
      }
    })
  }]
}
