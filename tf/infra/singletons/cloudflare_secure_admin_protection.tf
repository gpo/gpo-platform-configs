# Geo-restrict secure.gpo.ca admin routes to Ontario, Canada.
#
# Staged rollout: only staging.secure.gpo.ca is in scope for this PR. A
# follow-up PR appends "secure.gpo.ca" to secure_admin_geo_hosts once the
# staging rule has been verified (see docs/cloudflare-secure-admin-geo.md).
#
# CONFLICT WARNING: Cloudflare allows only one ruleset per zone per phase.
# Unmerged PR #203 adds a separate cloudflare_ruleset for
# phase = "http_request_firewall_custom" on this same zone (WordPress
# protection). Whichever of these two PRs lands second must fold its rule(s)
# into the single ruleset resource the other PR created, or the apply will
# fail / one ruleset will silently replace the other.
locals {
  secure_admin_geo_hosts = ["staging.secure.gpo.ca"]
}

resource "cloudflare_ruleset" "secure_gpo_ca_admin_protection" {
  zone_id = cloudflare_zone.gpo_ca.id
  name    = "secure.gpo.ca admin protection"
  kind    = "zone"
  phase   = "http_request_firewall_custom"

  rules {
    description = "Block admin/login/CiviCRM-admin routes on secure.gpo.ca from outside Ontario, Canada"
    enabled     = true
    action      = "block"

    # ip.src.subdivision_1_iso_code requires a Business/Enterprise Cloudflare
    # plan. If the API rejects this field because the zone is on a lower
    # tier, swap in the country-only fallback below (commented out) as an
    # interim measure until the plan is upgraded or confirmed.
    expression = format(
      "(http.host in {%s}) and (starts_with(http.request.uri.path, \"/admin\") or http.request.uri.path eq \"/user/login\" or starts_with(http.request.uri.path, \"/civicrm/admin\") or starts_with(http.request.uri.path, \"/civicrm/a/\")) and (not (ip.src.country eq \"CA\" and ip.src.subdivision_1_iso_code eq \"ON\"))",
      join(" ", [for host in local.secure_admin_geo_hosts : format("\"%s\"", host)])
    )

    # Fallback if subdivision fields are unavailable on this plan tier
    # (country-only block; does not restrict to Ontario specifically):
    # expression = format(
    #   "(http.host in {%s}) and (starts_with(http.request.uri.path, \"/admin\") or http.request.uri.path eq \"/user/login\" or starts_with(http.request.uri.path, \"/civicrm/admin\") or starts_with(http.request.uri.path, \"/civicrm/a/\")) and (ip.src.country ne \"CA\")",
    #   join(" ", [for host in local.secure_admin_geo_hosts : format("\"%s\"", host)])
    # )
  }
}
