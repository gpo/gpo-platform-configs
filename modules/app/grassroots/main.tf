locals {
  uri = "https://grassroots.${var.cloudflare_zone.zone}"
}

resource "google_iam_oauth_client" "grassroots" {
  oauth_client_id       = "gpo-grassroots-${var.environment}"
  display_name          = "GPO Grassroots"
  description           = "Grassroots app for ${local.uri}"
  location              = "global"
  disabled              = false
  allowed_grant_types   = ["AUTHORIZATION_CODE_GRANT"]
  allowed_redirect_uris = [local.uri]
  allowed_scopes        = ["https://www.googleapis.com/auth/cloud-platform"]
  client_type           = "CONFIDENTIAL_CLIENT"
}

resource "google_iam_oauth_client_credential" "grassroots" {
  oauthclient                = google_iam_oauth_client.grassroots.oauth_client_id
  location                   = google_iam_oauth_client.grassroots.location
  oauth_client_credential_id = "grassroots"
  display_name               = "Grassroots ${var.environment}"
}
