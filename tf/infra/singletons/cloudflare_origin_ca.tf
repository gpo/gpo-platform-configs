# Cloudflare Origin CA certificate for the WordPress droplets' proxied vhosts.
# Browsers never see it: Cloudflare terminates TLS at the edge and trusts this
# certificate on the edge-to-origin leg, including under the "strict" SSL mode.
# It is not publicly trusted, so it must only be served on proxied hostnames.
#
# scripts/install-origin-cert.sh copies the certificate and key to a droplet.
# The private key lives in this stack's state.

resource "tls_private_key" "gpo_ca_origin" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_cert_request" "gpo_ca_origin" {
  private_key_pem = tls_private_key.gpo_ca_origin.private_key_pem

  subject {
    common_name  = "gpo.ca"
    organization = "Green Party of Ontario"
  }
}

resource "cloudflare_origin_ca_certificate" "gpo_ca_origin" {
  csr                = tls_cert_request.gpo_ca_origin.cert_request_pem
  hostnames          = ["gpo.ca", "*.gpo.ca", "*.secure.gpo.ca"]
  request_type       = "origin-rsa"
  requested_validity = 5475
}

output "gpo_ca_origin_certificate_pem" {
  value       = cloudflare_origin_ca_certificate.gpo_ca_origin.certificate
  sensitive   = true
  description = "Origin CA certificate for proxied gpo.ca hostnames. Installed by scripts/install-origin-cert.sh."
}

output "gpo_ca_origin_private_key_pem" {
  value       = tls_private_key.gpo_ca_origin.private_key_pem
  sensitive   = true
  description = "Private key for gpo_ca_origin_certificate_pem. Installed by scripts/install-origin-cert.sh."
}
