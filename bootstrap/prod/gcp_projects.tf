resource "google_project" "gpo_data" {
  name            = "gpo-data-prod"
  project_id      = "gpo-data-prod"
  org_id          = local.gcp_org_id
  billing_account = local.gcp_billing_account
}
