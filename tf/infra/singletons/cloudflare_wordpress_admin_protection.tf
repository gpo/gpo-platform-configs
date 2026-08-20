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

  # Requests per source IP allowed within the counting window before
  # Cloudflare starts blocking that IP. Free-plan rate-limit rules are only
  # entitled to a 10-second window (period=60 is rejected at apply:
  # "not entitled to use the period 60, can only use a period among [10]"),
  # and the mitigation timeout is likewise pinned to that same 10 seconds
  # ("not entitled to use a mitigation timeout different from 10" — Business+
  # unlocks independent period/timeout values). So this isn't "5 attempts,
  # then locked out for 10 minutes" as originally designed; it's closer to a
  # burst limiter: exceed 5 POSTs in a 10-second window and every POST in
  # the next 10 seconds is blocked, then the window resets. Still stops
  # scripted rapid-fire submission; doesn't stop slow, patient brute force.
  wp_login_rate_limit_period_seconds  = 10
  wp_login_rate_limit_requests_period = 5
  wp_login_rate_limit_block_seconds   = 10

  # Source IPs exempt from the rate limit below (staff/office/monitoring —
  # traffic that legitimately POSTs to these paths repeatedly during testing).
  wp_login_rate_limit_allowlist_ips = ["142.93.48.15"]

  wp_login_rate_limit_allowlist_expression = format("(ip.src in {%s})", join(" ", local.wp_login_rate_limit_allowlist_ips))

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
# WAF custom rules. Free-plan budget: 5 per zone, all used.
#
# This ruleset already existed on the zone with 3 dashboard-managed rules
# fighting credit-card-testing fraud on the donation forms (an attacker
# validates stolen card numbers by running small charges through payment
# forms). Per the zone owner: drop the wp2shell REST-batch rule (a stale WP
# exploit mitigation, superseded by rule 2 below), keep and import the other
# two verbatim so `tofu apply` reconciles instead of conflicting ("A similar
# configuration with rules already exists" — Cloudflare refuses to create a
# second ruleset in this phase). Import first:
#
#   tofu import 'cloudflare_ruleset.gpo_ca_admin_route_protection' <zone_id>/<ruleset_id>
#
# Find <ruleset_id> via the dashboard (Security > WAF > Custom rules > the
# existing ruleset's URL/API) or:
#
#   curl -s -H "Authorization: Bearer $CF_API_TOKEN" \
#     "https://api.cloudflare.com/client/v4/zones/<zone_id>/rulesets/phases/http_request_firewall_custom/entrypoint" \
#     | jq '.result.id'
#
# After import, `tofu plan` will show: the wp2shell rule removed, the two
# fraud rules unchanged (verify the plan says "no changes" for those two,
# not "replace" — if it wants to replace them, the expressions below don't
# match production exactly and need adjusting before apply), and the three
# new rules added.
#
# Rules 1-2 are zone-wide (unscoped by waf_host_expression) because they are
# live fraud mitigations already protecting production — staging them would
# turn off active protection. Rules 3-5 are the new admin-protection work
# and stay staging-scoped per the rollout in docs/cloudflare-waf.md.
# ---------------------------------------------------------------------------
resource "cloudflare_ruleset" "gpo_ca_admin_route_protection" {
  zone_id = cloudflare_zone.gpo_ca.id
  # Must stay "default": that's the live name of the zone's existing
  # http_request_firewall_custom entry-point ruleset (imported, not
  # created), and `name` forces replacement — changing it would destroy
  # and recreate the whole ruleset, briefly dropping every rule in it,
  # including the pre-existing fraud rules. Individual rule `description`
  # fields carry the human-readable names instead.
  name  = "default"
  kind  = "zone"
  phase = "http_request_firewall_custom"

  # Pre-existing: blocks a known card-testing-fraud source IP outright,
  # regardless of geography. Kept first so it's evaluated before the
  # broader geo challenge below.
  rules {
    action      = "block"
    description = "Block known abusive IP (card-testing fraud)"
    enabled     = true
    expression  = "(ip.src eq 136.116.198.170)"
  }

  # Consolidated: unused WordPress endpoints, REST/author-archive user
  # enumeration, and PHP execution under upload directories. Each was
  # confirmed against the gpo/gpo-ca source rather than assumed from a
  # generic checklist:
  #   xmlrpc.php         — not disabled anywhere in code, and nothing calls it
  #   wp-comments-post   — comments_open is filtered to __return_false site-wide
  #   wp-signup/register — no public registration; only staff have accounts
  #   trackback          — pingback/trackback surface, unused with comments off
  #   /wp-json/wp/v2/users, ?author=<id> — leak usernames that feed credential
  #     stuffing; the theme only uses the gpo-action-blocks/v1 REST namespace
  #   /uploads (gpo.ca), /sites/default/files (secure.gpo.ca) — WP_CONTENT_DIR
  #     is the web root and Drupal's public files dir doubles as CiviCRM's
  #     upload target; nothing legitimate serves PHP from either
  # All blocked outright: a challenge page still costs a round trip, and
  # there is no legitimate traffic to preserve on any of these paths.
  rules {
    action      = "block"
    description = "Block unused WP endpoints, user enumeration, and PHP under upload dirs"
    enabled     = true
    expression  = <<-EOT
      (${local.waf_host_expression} and ((http.request.uri.path in {"/wordpress/xmlrpc.php" "/xmlrpc.php" "/wordpress/wp-comments-post.php" "/wp-comments-post.php" "/wordpress/wp-signup.php" "/wp-signup.php" "/wordpress/wp-register.php" "/wp-register.php"}) or (ends_with(http.request.uri.path, "/trackback")) or (ends_with(http.request.uri.path, "/trackback/"))))
      or (${local.waf_host_expression} and ((starts_with(http.request.uri.path, "/wp-json/wp/v2/users")) or (starts_with(http.request.uri.query, "author=")) or (http.request.uri.query contains "&author=")))
      or (((${local.waf_host_expression} and starts_with(http.request.uri.path, "/uploads/")) or (${local.secure_host_expression} and starts_with(http.request.uri.path, "/sites/default/files/"))) and ((ends_with(http.request.uri.path, ".php")) or (ends_with(http.request.uri.path, ".php3")) or (ends_with(http.request.uri.path, ".php4")) or (ends_with(http.request.uri.path, ".php5")) or (ends_with(http.request.uri.path, ".php7")) or (ends_with(http.request.uri.path, ".php8")) or (ends_with(http.request.uri.path, ".phtml")) or (ends_with(http.request.uri.path, ".phar"))))
    EOT
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

  # Pre-existing: the zone's general card-testing-fraud mitigation, applying
  # to every request (not just admin routes) since fraud hits the public
  # donation/contribution forms. Kept last: rules 2-4 above should get first
  # crack at admin-path traffic since they're more specific (block instead
  # of challenge), and nothing follows this rule in the ruleset either way.
  rules {
    action      = "managed_challenge"
    description = "IPs outside Canada receive challenge"
    enabled     = true
    expression  = "(not ip.src.country in {\"CA\" \"US\"})"
  }
}

# ---------------------------------------------------------------------------
# Rate limiting — throttle anonymous write POSTs per source IP: the login
# forms (wp-login.php, /user/login, /user/password), gpo.ca's /api/* form
# handlers (create CiviCRM contacts and send mail with no captcha of their
# own), and secure.gpo.ca's donation charge endpoint (the card-testing-fraud
# target — see the pre-existing fraud rules in the ruleset above).
# Legitimate traffic never POSTs 5 times in 10 seconds across these.
# Exempts local.wp_login_rate_limit_allowlist_ips (staff/monitoring).
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
    description = "Rate limit login/donation/api form POSTs per source IP"
    enabled     = true
    expression  = "((${local.waf_host_expression} and (${local.wp_login_path_expression} or starts_with(http.request.uri.path, \"/api/\"))) or (${local.secure_host_expression} and (http.request.uri.path in {\"/user/login\" \"/user/password\" \"/civicrm/contribute/transact\"}))) and (http.request.method eq \"POST\") and not (${local.wp_login_rate_limit_allowlist_expression})"

    ratelimit {
      characteristics     = ["cf.colo.id", "ip.src"]
      period              = local.wp_login_rate_limit_period_seconds
      requests_per_period = local.wp_login_rate_limit_requests_period
      mitigation_timeout  = local.wp_login_rate_limit_block_seconds
    }
  }
}
