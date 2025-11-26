output "ingress_ip" {
  value = google_compute_global_address.gke_ingress_ip.address
}
