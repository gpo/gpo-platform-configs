resource "google_compute_network" "main" {
  depends_on              = [google_project_service.compute]
  name                    = "${var.name}-${var.environment}"
  auto_create_subnetworks = true
}

resource "google_service_account" "main" {
  account_id   = "gke-${var.name}-${var.environment}"
  display_name = "GKE ${var.name} ${var.environment}"
}

resource "google_container_cluster" "main" {
  depends_on = [
    google_project_service.compute,
    google_project_service.container,
  ]
  deletion_protection = false
  name                = "${var.name}-${var.environment}"
  location            = var.location
  initial_node_count  = 3

  network = google_compute_network.main.name

  gateway_api_config {
    channel = "CHANNEL_STANDARD"
  }

  node_config {
    resource_labels = {
      "goog-gke-node-pool-provisioning-model" = "on-demand"
    }
    service_account = google_service_account.main.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}
