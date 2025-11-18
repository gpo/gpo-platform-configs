resource "google_compute_global_address" "gke_ingress_ip" {
  project      = "gpo-eng-stage"
  name         = "gke-ingress-ip"
  address_type = "EXTERNAL"
  ip_version   = "IPV4"
}

# Helps with being able to see the IP we end up getting.
output "gke_ingress_ip" {
  value = google_compute_global_address.gke_ingress_ip.address
}
