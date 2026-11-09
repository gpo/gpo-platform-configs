# Browser cache lifetimes for gpo.ca static files.
#
# The origin (nginx) sends no Cache-Control, so without these rules every
# static file gets the zone's default Browser Cache TTL of 4 hours and repeat
# visitors re-download CSS, JS, fonts, and images several times a day.
#
# When several cache rules match, later rules override earlier ones for the
# same setting, so the general rule comes first and the versioned rule last.
#
# secure.gpo.ca is left on the zone default: CiviCRM serves generated assets
# through its asset builder, and their URLs do not change when the content
# does.
locals {
  cache_rule_host_expression = "(http.host in {\"gpo.ca\" \"staging.gpo.ca\"})"
  static_extensions          = "{\"js\" \"css\" \"map\" \"png\" \"jpg\" \"jpeg\" \"gif\" \"svg\" \"webp\" \"avif\" \"ico\" \"woff\" \"woff2\" \"ttf\" \"otf\"}"
}

resource "cloudflare_ruleset" "gpo_ca_cache_settings" {
  zone_id = cloudflare_zone.gpo_ca.id
  name    = "gpo.ca cache settings"
  kind    = "zone"
  phase   = "http_request_cache_settings"

  # Uploads, fonts, and theme images keep their URL when the file changes
  # (Enable Media Replace overwrites uploads in place, and fonts and images
  # referenced from CSS carry no version), so a week bounds how long a
  # returning visitor can see a stale copy.
  rules {
    action      = "set_cache_settings"
    description = "Static files: cache in browsers for 7 days"
    enabled     = true
    expression  = "${local.cache_rule_host_expression} and (http.request.uri.path.extension in ${local.static_extensions})"

    action_parameters {
      browser_ttl {
        mode    = "override_origin"
        default = 604800
      }
    }
  }

  # WordPress appends ?ver= to enqueued CSS and JS (the theme and gpo plugins
  # use the file's mtime, core and third-party plugins their release
  # version), so a changed file gets a new URL and can be cached for a year.
  rules {
    action      = "set_cache_settings"
    description = "Versioned CSS and JS: cache in browsers for a year"
    enabled     = true
    expression  = "${local.cache_rule_host_expression} and (http.request.uri.path.extension in {\"js\" \"css\"}) and (http.request.uri.query contains \"ver=\")"

    action_parameters {
      browser_ttl {
        mode    = "override_origin"
        default = 31536000
      }
    }
  }
}
