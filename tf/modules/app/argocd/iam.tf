resource "google_service_account" "main" {
  account_id   = "argocd"
  display_name = "argocd"
}

# grant our GCP service account the ability to use this key for decryption
resource "google_kms_crypto_key_iam_member" "decrypt" {
  crypto_key_id = var.kms_key_id
  role          = "roles/cloudkms.cryptoKeyDecrypter"
  member        = google_service_account.main.member
}

resource "google_project_iam_member" "sa_usage_consumer" {
  project = var.bootstrap_project
  role    = "roles/serviceusage.serviceUsageConsumer"
  member  = google_service_account.main.member
}

# grant our K8s service account the ability to use this GCP service account
resource "google_service_account_iam_member" "wi_user" {
  service_account_id = google_service_account.main.id
  role               = "roles/iam.workloadIdentityUser"
  # note: the [argocd/argocd-server] is [namespace/svc_account]
  # this tells google that this GOOGLE svc account can only be used by the K8s svc account "argocd-server" in the ns "argocd"
  member = "serviceAccount:${data.google_client_config.current.project}.svc.id.goog[argocd/argocd-server]"
}
