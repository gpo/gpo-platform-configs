locals {
  /* A list of all the secrets in google secret manager which the external secrets operator will be granted access to.
     Must be present in the output of: `gcloud secrets list`
  */
  secrets = [
    "superset-config",
    "superset-env",
    "superset-postgres-db"
  ]
}

resource "google_service_account" "main" {
  account_id   = "external-secrets"
  display_name = "external-secrets"
}

# grant our GCP service account the ability to access secrets
resource "google_secret_manager_secret_iam_member" "main" {
  for_each  = toset(local.secrets)
  secret_id = "projects/${data.google_client_config.current.project}/secrets/${each.value}"
  role      = "roles/secretmanager.secretAccessor"
  member    = google_service_account.main.member
}

# grant our K8s service account the ability to use this GCP service account
resource "google_service_account_iam_member" "wi_user" {
  service_account_id = google_service_account.main.id
  role               = "roles/iam.workloadIdentityUser"
  # note: the [external-secrets/external-secrets] is [namespace/svc_account]
  # tells GCP that this GOOGLE svc account can only be used by the K8s svc account "external-secrets-server" in the ns "external-secrets"
  member = "serviceAccount:${data.google_client_config.current.project}.svc.id.goog[external-secrets/external-secrets]"
}
