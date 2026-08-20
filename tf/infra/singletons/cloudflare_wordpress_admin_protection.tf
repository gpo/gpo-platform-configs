# Harden Cloudflare-level protection for the sites on the gpo.ca zone.
#
# Scoped by hostname: waf_enforced_hosts covers the gpo.ca WordPress
# install; secure_admin_geo_hosts covers the secure.gpo.ca Drupal + CiviCRM
# site, whose admin geo restriction is folded into the non-CA block rule
# and login rate limit here because Cloudflare allows one ruleset per zone
# per phase. ontariogreens.ca needs nothing: its zone
# (cloudflare_ontariogreens.tf) 301-redirects everything to gpo.ca.
#
# Every expression below sticks to Free-plan-safe operators (eq, in,
# starts_with, ends_with, contains). The regex `matches` operator and the
# province-level geo fields (ip.src.region_code and friends) require a
# Business plan, so "outside Ontario" is approximated as "outside Canada"
# until/unless the zone is upgraded.
#
# Paths were derived from the gpo/gpo-ca source and the production nginx
# config rather than a generic WordPress checklist — see
# docs/cloudflare-waf.md for what was verified and the open items.
#
# https://github.com/gpo/gpo-platform-configs/issues/202

locals {
  # Staged rollout: rules only fire on these hostnames. The singletons stack
  # has no stage tier, so staging happens inside the zone — phase 1 enforces
  # on staging.gpo.ca only; phase 2 (separate PR, after verifying staging)
  # adds "gpo.ca" and "www.gpo.ca".
  waf_enforced_hosts = ["staging.gpo.ca"]

  waf_host_expression = format("(http.host in {%s})", join(" ", [for h in local.waf_enforced_hosts : format("%q", h)]))

  # secure.gpo.ca (Drupal + CiviCRM) shares this zone, and Cloudflare allows
  # only one http_request_firewall_custom ruleset per zone, so its admin geo
  # restriction lives in this ruleset too (folded into the non-CA block rule
  # below; see docs/cloudflare-waf.md). It stages
  # independently: phase 1 is staging.secure.gpo.ca only; a follow-up PR adds
  # "secure.gpo.ca" after verifying the donation flow stays reachable.
  secure_admin_geo_hosts = ["staging.secure.gpo.ca"]

  secure_host_expression = format("(http.host in {%s})", join(" ", [for h in local.secure_admin_geo_hosts : format("%q", h)]))

  # Admin surface only — donation/contact paths (/civicrm/contribute/*, etc.)
  # must stay reachable worldwide.
  secure_admin_route_expression = "((starts_with(http.request.uri.path, \"/admin\")) or (http.request.uri.path eq \"/user/login\") or (starts_with(http.request.uri.path, \"/civicrm/admin\")) or (starts_with(http.request.uri.path, \"/civicrm/a/\")))"

  # Requests per source IP per minute allowed to POST the login form before
  # Cloudflare starts blocking that IP.
  wp_login_rate_limit_requests_per_minute = 5
  wp_login_rate_limit_block_seconds       = 600

  # gpo-ca is a Bedrock-style install: WP core lives under /wordpress
  # (ABSPATH = web/wordpress/), so the real admin surface is
  # /wordpress/wp-admin and the real login is /wordpress/wp-login.php.
  # Production is nginx + PHP-FPM with no rewrite aliasing the bare /wp-*
  # paths (they 404 at the origin), but scanners hammer them constantly, so
  # they are matched too — cheap at the edge, and future-proof against a
  # Redirection-plugin alias appearing.
  #
  # admin-ajax.php is excluded: it is WordPress's public AJAX gateway and
  # Composer-installed plugins (Gravity Forms, Popup Maker, TotalContest)
  # may use it from the anonymous front end. /wp-json is likewise untouched:
  # the public action blocks call /wp-json/gpo-action-blocks/v1/* directly.
  wp_admin_route_expression = "((http.request.uri.path eq \"/wordpress/wp-login.php\") or (http.request.uri.path eq \"/wp-login.php\") or (starts_with(http.request.uri.path, \"/wordpress/wp-admin\") and http.request.uri.path ne \"/wordpress/wp-admin/admin-ajax.php\") or (starts_with(http.request.uri.path, \"/wp-admin\") and http.request.uri.path ne \"/wp-admin/admin-ajax.php\"))"

  wp_login_path_expression = "((http.request.uri.path eq \"/wordpress/wp-login.php\") or (http.request.uri.path eq \"/wp-login.php\"))"
}

# ---------------------------------------------------------------------------
# WAF custom rules — WordPress admin/login route protection
#
# Free-plan budget: 5 custom rules per zone. All 5 are used here.
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
    expression  = "${local.waf_host_expression} and ((http.request.uri.path in {\"/wordpress/xmlrpc.php\" \"/xmlrpc.php\" \"/wordpress/wp-comments-post.php\" \"/wp-comments-post.php\" \"/wordpress/wp-signup.php\" \"/wp-signup.php\" \"/wordpress/wp-register.php\" \"/wp-register.php\"}) or (ends_with(http.request.uri.path, \"/trackback\")) or (ends_with(http.request.uri.path, \"/trackback/\")))"
  }

  # WordPress exposes contributors at /wp-json/wp/v2/users and redirects
  # /?author=<id> to the author archive, both of which leak valid usernames
  # to feed credential stuffing. The theme never queries either, and the only
  # REST namespace the front end uses is gpo-action-blocks/v1.
  rules {
    action      = "block"
    description = "Block WordPress user enumeration (REST users endpoint, author archives)"
    enabled     = true
    expression  = "${local.waf_host_expression} and ((starts_with(http.request.uri.path, \"/wp-json/wp/v2/users\")) or (starts_with(http.request.uri.query, \"author=\")) or (http.request.uri.query contains \"&author=\"))"
  }

  # Admins are all in Ontario. Province-level matching needs a Business plan,
  # so this blocks at country granularity; tighten to
  # `ip.src.region_code ne "ON"` if the zone is ever upgraded. Ordered before
  # the challenge rule so blocked traffic never reaches it.
  rules {
    action      = "block"
    description = "Block non-Canadian traffic to admin surfaces (gpo.ca WordPress, secure.gpo.ca Drupal/CiviCRM)"
    enabled     = true
    expression  = "((${local.waf_host_expression} and ${local.wp_admin_route_expression}) or (${local.secure_host_expression} and ${local.secure_admin_route_expression})) and (ip.src.country ne \"CA\")"
  }

  rules {
    action      = "managed_challenge"
    description = "Challenge traffic to WordPress admin/login surfaces"
    enabled     = true
    expression  = "${local.waf_host_expression} and ${local.wp_admin_route_expression}"
  }

  # Defence in depth against an upload-to-RCE chain, on both sites. gpo.ca:
  # WP_CONTENT_DIR is the web root (CONTENT_DIR = ""), so media lands in
  # /uploads. secure.gpo.ca: Drupal's public files (and CiviCRM's uploads
  # under it) live at /sites/default/files. Nothing legitimate serves PHP
  # out of either.
  rules {
    action      = "block"
    description = "Block PHP execution under upload directories (/uploads, /sites/default/files)"
    enabled     = true
    expression  = "((${local.waf_host_expression} and starts_with(http.request.uri.path, \"/uploads/\")) or (${local.secure_host_expression} and starts_with(http.request.uri.path, \"/sites/default/files/\"))) and ((ends_with(http.request.uri.path, \".php\")) or (ends_with(http.request.uri.path, \".php3\")) or (ends_with(http.request.uri.path, \".php4\")) or (ends_with(http.request.uri.path, \".php5\")) or (ends_with(http.request.uri.path, \".php7\")) or (ends_with(http.request.uri.path, \".php8\")) or (ends_with(http.request.uri.path, \".phtml\")) or (ends_with(http.request.uri.path, \".phar\")))"
  }
}

# ---------------------------------------------------------------------------
# Rate limiting — throttle anonymous write POSTs per source IP: the login
# forms (wp-login.php, /user/login) and gpo.ca's /api/* form handlers, which
# create CiviCRM contacts and send mail with no captcha of their own.
# Legitimate users never POST 5 times in a minute across these.
#
# Free-plan budget: 1 rate limiting rule per zone.
# ---------------------------------------------------------------------------
resource "cloudflare_ruleset" "gpo_ca_wp_login_rate_limit" {
  zone_id = cloudflare_zone.gpo_ca.id
  name    = "Login rate limit"
  kind    = "zone"
  phase   = "http_ratelimit"

  rules {
    action      = "block"
    description = "Rate limit login and /api form POSTs per source IP"
    enabled     = true
    expression  = "((${local.waf_host_expression} and (${local.wp_login_path_expression} or starts_with(http.request.uri.path, \"/api/\"))) or (${local.secure_host_expression} and (http.request.uri.path eq \"/user/login\"))) and (http.request.method eq \"POST\")"

    ratelimit {
      characteristics     = ["cf.colo.id", "ip.src"]
      period              = 60
      requests_per_period = local.wp_login_rate_limit_requests_per_minute
      mitigation_timeout  = local.wp_login_rate_limit_block_seconds
    }
  }
}
