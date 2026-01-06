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

  /*
  enable the gateway api
  https://docs.cloud.google.com/kubernetes-engine/docs/concepts/gateway-api
  */
  gateway_api_config {
    channel = "CHANNEL_STANDARD"
  }

  node_config {
    /* google's cluster autoscaler wants this label to be there */
    resource_labels = {
      "goog-gke-node-pool-provisioning-model" = "on-demand"
    }

    /* our nodes will authenticate themselves to google using this service account */
    service_account = google_service_account.main.email

    /* scopes used by node auto provisioning and GKE autopilot */
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    /*
    enable the GKE metadata server
    https://docs.cloud.google.com/kubernetes-engine/docs/concepts/workload-identity#metadata_server
    */
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }

  /*
  enable workload identity
  https://docs.cloud.google.com/kubernetes-engine/docs/how-to/workload-identity
  */
  workload_identity_config {
    workload_pool = "${data.google_client_config.current.project}.svc.id.goog"
  }
}
