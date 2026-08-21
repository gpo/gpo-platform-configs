# our primary VPC - everything lives in here
resource "google_compute_network" "main" {
  depends_on              = [google_project_service.compute]
  name                    = "${var.name}-${var.environment}"
  auto_create_subnetworks = true
}

# We need at least one load balancer provisioned by the Kubernetes resources we
# create in the GKE cluster. It's better to reserve a static IP for the load
# balancer. This is that static IP.
resource "google_compute_global_address" "gke_ingress_ip" {
  name         = "gke-ingress-ip"
  address_type = "EXTERNAL"
  ip_version   = "IPV4"
  depends_on = [
    google_project_service.compute
  ]
}

# this is a block of IP addresses in our VPC that we will allow Google to use
# for connecting us to CloudSQL / Redis / Whatever managed services we're using.
resource "google_compute_global_address" "managed_services" {
  name          = "gcp-peering-private-ip-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.main.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.main.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.managed_services.name]
}
