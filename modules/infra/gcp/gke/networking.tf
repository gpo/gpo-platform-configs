# We need at least one load balancer provisioned by the Kubernetes resources we
# create in the GKE cluster. It's better to reserve a static IP for the load
# balancer. This is that static IP.
resource "google_compute_global_address" "gke_ingress_ip" {
  name         = "gke-ingress-ip"
  address_type = "EXTERNAL"
  ip_version   = "IPV4"
}
