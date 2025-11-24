# We need at least one load balancer provisioned by the Kubernetes resources we
# create in the GKE cluster. It's better to reserve a static IP for the load
# balancer. This is that static IP.
resource "google_compute_global_address" "gke_ingress_ip" {
  name         = "gke-ingress-ip"
  address_type = "EXTERNAL"
  ip_version   = "IPV4"
}

# Some of our DNS records live in this module because their lifecycles align
# with the GKE cluster. We want them to come and go as the GKE cluster is
# created and destroyed, and we want them to be able to reference data from
# other resources like GCP reserved static IPs.

# The DNS record for the Superset app.
resource "cloudflare_record" "superset" {
  zone_id = var.cloudflare_zone_id // was from cloudflare_zone.gpo_ca.id before
  name    = "superset.${var.environment}.gke.gpo.ca"
  content = google_compute_global_address.gke_ingress_ip.address
  type    = "A"
  ttl     = 300
  proxied = false
}
