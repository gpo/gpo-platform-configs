resource "google_project" "gpo_data" {
  name            = "gpo-data-stage"
  project_id      = "calm-segment-466901-e4"
  org_id          = local.gcp_org_id
  billing_account = local.gcp_billing_account
}

resource "google_project" "gpo_eng" {
  name            = "gpo-eng-stage"
  project_id      = "gpo-eng-stage"
  org_id          = local.gcp_org_id
  billing_account = local.gcp_billing_account
}
