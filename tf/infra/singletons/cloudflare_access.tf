# ---------------------------------------------------------------------------
# islandgetaway — gate preview deployments (*.pages.dev) behind Access
# ---------------------------------------------------------------------------
resource "cloudflare_zero_trust_access_application" "islandgetaway_previews" {
  account_id       = data.sops_file.secrets.data["cloudflare_account_id"]
  name             = "islandgetaway previews"
  domain           = "*.islandgetaway-ca.pages.dev"
  type             = "self_hosted"
  session_duration = "24h"

  # One-time PIN is enabled by default on all Cloudflare accounts; no IdP
  # resource is needed.
  allowed_idps              = []
  auto_redirect_to_identity = false
}

resource "cloudflare_zero_trust_access_policy" "islandgetaway_previews_allow_gpo" {
  account_id     = data.sops_file.secrets.data["cloudflare_account_id"]
  application_id = cloudflare_zero_trust_access_application.islandgetaway_previews.id
  name           = "Allow @gpo.ca"
  precedence     = 1
  decision       = "allow"

  include {
    email_domain = ["gpo.ca"]
  }
}
