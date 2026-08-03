# Harden Cloudflare-level protection for the WordPress site at gpo.ca.
#
# Scoped to the gpo.ca WordPress install specifically. secure.gpo.ca is a
# Drupal + CiviCRM site on the same zone with a completely different admin
# surface (/user/login, /civicrm/*) and is NOT covered by these rules.
#
# Paths and exclusions here were derived from the gpo/gpo-ca source rather
# than a generic WordPress checklist — see docs/cloudflare-waf.md for what
# was verified, what's already handled in code, and the open items.
#
# https://github.com/gpo/gpo-platform-configs/issues/202

locals {
  # Requests per source IP per minute allowed to POST the login form before
  # Cloudflare starts blocking that IP.
  wp_login_rate_limit_requests_per_minute = 5
  wp_login_rate_limit_block_seconds       = 600

  # Off by default. Hard-challenging non-CA traffic to admin routes needs the
  # travelling-admin exception process documented in docs/cloudflare-waf.md
  # agreed on before it's safe to flip on.
  restrict_admin_routes_to_canada = false

  # gpo-ca is a Bedrock-style install: WP core lives under /wordpress
  # (WP_SITEURL=https://gpo.ca/wordpress), so the real admin surface is
  # /wordpress/wp-admin and the real login is /wordpress/wp-login.php.
  # The bare /wp-* paths are matched too — nothing serves them, but scanners
  # hammer them constantly and .htaccess routes unknown paths into index.php,
  # so matching at the edge saves the origin a PHP bootstrap per probe.
  #
  # admin-ajax.php is excluded: third-party plugins (Gravity Forms, Popup
  # Maker, TotalContest) are Composer-installed rather than vendored into the
  # repo, so their front-end AJAX use can't be ruled out from source. Leaving
  # it unchallenged is the conservative choice.
  wp_admin_route_expression = "((http.request.uri.path eq \"/wordpress/wp-login.php\") or (http.request.uri.path eq \"/wp-login.php\") or (starts_with(http.request.uri.path, \"/wordpress/wp-admin\") and http.request.uri.path ne \"/wordpress/wp-admin/admin-ajax.php\") or (starts_with(http.request.uri.path, \"/wp-admin\") and http.request.uri.path ne \"/wp-admin/admin-ajax.php\"))"

  wp_login_path_expression = "((http.request.uri.path eq \"/wordpress/wp-login.php\") or (http.request.uri.path eq \"/wp-login.php\"))"
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

  # Endpoints gpo-ca verifiably does not use. Each was confirmed against the
  # gpo/gpo-ca source rather than assumed from a generic WordPress checklist:
  #   xmlrpc.php        — not disabled anywhere in code, and nothing calls it
  #   wp-comments-post  — comments_open is filtered to __return_false site-wide
  #   wp-signup/register— no public registration; only staff have accounts
  #   trackback         — pingback/trackback surface, unused with comments off
  # Blocked outright rather than challenged: a challenge page still costs a
  # round trip, and there is no legitimate traffic to preserve here.
  rules {
    action      = "block"
    description = "Block unused WordPress endpoints (xmlrpc, comments, signup, trackback)"
    enabled     = true
    expression  = "((http.request.uri.path matches \"^(/wordpress)?/xmlrpc\\\\.php$\") or (http.request.uri.path matches \"^(/wordpress)?/wp-comments-post\\\\.php$\") or (http.request.uri.path matches \"^(/wordpress)?/wp-(signup|register)\\\\.php$\") or (http.request.uri.path matches \"/trackback/?$\"))"
  }

  # WordPress exposes contributors at /wp-json/wp/v2/users and redirects
  # /?author=<id> to the author archive, both of which leak valid usernames to
  # feed the credential-stuffing traffic the rules above are meant to raise the
  # cost of. The theme never queries either, and the only REST namespace the
  # front end uses is gpo-action-blocks/v1, so neither is load-bearing.
  rules {
    action      = "block"
    description = "Block WordPress user enumeration (REST users endpoint, author archives)"
    enabled     = true
    expression  = "((starts_with(http.request.uri.path, \"/wp-json/wp/v2/users\")) or (http.request.uri.query matches \"(^|&)author=[0-9]+\"))"
  }

  rules {
    action      = "managed_challenge"
    description = "Challenge traffic to WordPress admin/login surfaces"
    enabled     = true
    expression  = local.wp_admin_route_expression
  }

  # Defence in depth against an upload-to-RCE chain. WP_CONTENT_DIR is the web
  # root here (CONTENT_DIR = ""), so media lands in /uploads, and unlike many
  # WordPress deployments web/.htaccess has no rule stopping the origin from
  # executing PHP there. Nothing legitimate serves a .php file out of /uploads.
  rules {
    action      = "block"
    description = "Block PHP execution under /uploads"
    enabled     = true
    expression  = "(starts_with(http.request.uri.path, \"/uploads/\") and http.request.uri.path matches \"\\\\.ph(p[0-9]?|tml|ar)$\")"
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
    expression  = "${local.wp_login_path_expression} and (http.request.method eq \"POST\")"

    ratelimit {
      characteristics     = ["ip.src"]
      period              = 60
      requests_per_period = local.wp_login_rate_limit_requests_per_minute
      mitigation_timeout  = local.wp_login_rate_limit_block_seconds
    }
  }
}
