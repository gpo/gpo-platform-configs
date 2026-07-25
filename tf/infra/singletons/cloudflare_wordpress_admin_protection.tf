# Harden Cloudflare-level protection for WordPress admin/login surfaces on
# the gpo.ca zone (gpo.ca, secure.gpo.ca, and any future WordPress site
# sharing this zone). See docs/cloudflare-waf.md for rationale, threshold
# choices, and the exception process for admins travelling outside Canada.
#
# https://github.com/gpo/gpo-platform-configs/issues/202

locals {
  # Requests per source IP per minute allowed to POST /wp-login.php before
  # Cloudflare starts blocking that IP.
  wp_login_rate_limit_requests_per_minute = 5
  wp_login_rate_limit_block_seconds       = 600

  # Off by default. Hard-challenging non-CA traffic to admin routes needs the
  # travelling-admin exception process documented in docs/cloudflare-waf.md
  # agreed on before it's safe to flip on.
  restrict_admin_routes_to_canada = false

  # admin-ajax.php lives under /wp-admin but is called by unauthenticated
  # front-end visitors (contact forms, WooCommerce, etc.), so it's excluded
  # from admin-route matching to avoid challenging normal site traffic.
  wp_admin_route_expression = "((http.request.uri.path eq \"/wp-login.php\") or (http.request.uri.path eq \"/xmlrpc.php\") or (starts_with(http.request.uri.path, \"/wp-admin\") and http.request.uri.path ne \"/wp-admin/admin-ajax.php\"))"
}

# ---------------------------------------------------------------------------
# Bot Fight Mode — free-tier bot mitigation, zone-wide.
#
# Super Bot Fight Mode fields (sbfm_*, optimize_wordpress) are left unset:
# they're Pro-plan-and-up features and the account's current plan tier
# hasn't been confirmed. Enable them here once that's known.
# ---------------------------------------------------------------------------
resource "cloudflare_bot_management" "gpo_ca" {
  zone_id    = cloudflare_zone.gpo_ca.id
  fight_mode = true
}

# ---------------------------------------------------------------------------
# WAF custom rules — WordPress admin/login route protection
# ---------------------------------------------------------------------------
resource "cloudflare_ruleset" "gpo_ca_admin_route_protection" {
  zone_id = cloudflare_zone.gpo_ca.id
  name    = "WordPress admin route protection"
  kind    = "zone"
  phase   = "http_request_firewall_custom"

  rules {
    action      = "managed_challenge"
    description = "Challenge traffic to WordPress admin/login surfaces"
    enabled     = true
    expression  = local.wp_admin_route_expression
  }

  rules {
    action      = "managed_challenge"
    description = "Challenge non-Canadian traffic to WordPress admin/login surfaces"
    enabled     = local.restrict_admin_routes_to_canada
    expression  = "${local.wp_admin_route_expression} and (ip.src.country ne \"CA\")"
  }
}

# ---------------------------------------------------------------------------
# Rate limiting — throttle POST /wp-login.php per source IP
# ---------------------------------------------------------------------------
resource "cloudflare_ruleset" "gpo_ca_wp_login_rate_limit" {
  zone_id = cloudflare_zone.gpo_ca.id
  name    = "wp-login.php rate limit"
  kind    = "zone"
  phase   = "http_ratelimit"

  rules {
    action      = "block"
    description = "Rate limit POST /wp-login.php per source IP"
    enabled     = true
    expression  = "(http.request.uri.path eq \"/wp-login.php\") and (http.request.method eq \"POST\")"

    ratelimit {
      characteristics     = ["ip.src"]
      period              = 60
      requests_per_period = local.wp_login_rate_limit_requests_per_minute
      mitigation_timeout  = local.wp_login_rate_limit_block_seconds
    }
  }
}
