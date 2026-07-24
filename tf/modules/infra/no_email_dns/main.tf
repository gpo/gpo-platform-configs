terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
  }
}

# Anti-spoofing records for a domain that doesn't send mail: tells receiving
# mail servers to reject anything claiming to be from it.

resource "cloudflare_record" "spf" {
  zone_id = var.zone_id
  name    = var.domain
  content = "v=spf1 -all"
  type    = "TXT"
  ttl     = 300
}

resource "cloudflare_record" "wildcard_domainkey" {
  zone_id = var.zone_id
  name    = "*._domainkey.${var.domain}"
  content = "v=DKIM1; p="
  type    = "TXT"
  ttl     = 300
}

resource "cloudflare_record" "dmarc" {
  zone_id = var.zone_id
  name    = "_dmarc.${var.domain}"
  content = "v=DMARC1; p=reject; sp=reject; adkim=s; aspf=s;"
  type    = "TXT"
  ttl     = 300
}
