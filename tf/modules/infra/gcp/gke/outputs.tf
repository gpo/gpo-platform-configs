output "ingress_ip" {
  value = google_compute_global_address.gke_ingress_ip.address
}

output "vpc_network_name" {
  value = google_compute_network.main.name
}
