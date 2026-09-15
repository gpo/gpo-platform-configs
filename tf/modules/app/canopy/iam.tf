resource "google_service_account" "main" {
  account_id   = "canopy"
  display_name = "canopy"
}

# this gives the canopy svc account storage admin capabilities on this bucket ONLY
resource "google_storage_bucket_iam_member" "main" {
  bucket = google_storage_bucket.main.name
  role   = "roles/storage.admin"
  member = google_service_account.main.member
}

# grant our K8s service account the ability to use this GCP service account
resource "google_service_account_iam_member" "wi_user" {
  service_account_id = google_service_account.main.id
  role               = "roles/iam.workloadIdentityUser"
  # note: the [canopy/canopy] is [namespace/svc_account]
  # tells GCP that this GOOGLE svc account can only be used by the K8s svc account "canopy" in the ns "canopy"
  member = "serviceAccount:${data.google_client_config.current.project}.svc.id.goog[canopy/canopy]"
}
