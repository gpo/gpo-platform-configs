# Cloudflare Pages

Relevant stack: `tf/infra/singletons/`

---

## Overview

Cloudflare Pages projects are defined in `tf/infra/singletons/`. The provider version is 4.48.0. Three resources are needed to fully deploy a Pages site with a custom domain:

1. `cloudflare_pages_project` — creates the project and wires up the GitHub repo
2. `cloudflare_record` — CNAME pointing the custom subdomain at `<project>.pages.dev`
3. `cloudflare_pages_domain` — attaches the custom domain to the project

---

## Pre-requisite: GitHub OAuth connection

Before the first `tofu apply`, the **Cloudflare Pages → GitHub connection must be authorised manually** in the Cloudflare dashboard:

**Workers & Pages → Overview → Settings → Integrations → GitHub**

Terraform cannot create this OAuth connection. If it doesn't exist the `cloudflare_pages_project` apply will fail.

---

## Full example

See `tf/infra/singletons/cloudflare_april_fools.tf` for a working reference. Template:

```hcl
resource "cloudflare_pages_project" "my_project" {
  account_id        = data.sops_file.secrets.data["cloudflare_account_id"]
  name              = "my-project-name"      # becomes <name>.pages.dev
  production_branch = "main"

  source {
    type = "github"
    config {
      owner                         = "gpo"
      repo_name                     = "my-repo"
      production_branch             = "main"
      pr_comments_enabled           = true
      deployments_enabled           = true
      production_deployment_enabled = true
      preview_deployment_setting    = "none"  # "all", "custom", or "none"
    }
  }

  build_config {
    build_command   = ""   # empty = no build step
    destination_dir = "/"  # serve from repo root
  }
}

resource "cloudflare_record" "my_subdomain_gpo_ca" {
  zone_id = cloudflare_zone.gpo_ca.id
  name    = "myapp.gpo.ca"
  content = cloudflare_pages_project.my_project.subdomain  # resolves to <name>.pages.dev
  type    = "CNAME"
  ttl     = 1
  proxied = true
}

resource "cloudflare_pages_domain" "my_subdomain_gpo_ca" {
  account_id   = data.sops_file.secrets.data["cloudflare_account_id"]
  project_name = cloudflare_pages_project.my_project.name
  domain       = "myapp.gpo.ca"
}
```

---

## source.config options

| Option | Type | Default | Notes |
|---|---|---|---|
| `owner` | string | — | GitHub org or username |
| `repo_name` | string | — | Repository name (no org prefix) |
| `production_branch` | string | — | **Required.** Branch for prod deployments |
| `deployments_enabled` | bool | `true` | Master switch for all deployments |
| `production_deployment_enabled` | bool | `true` | Enable prod branch deploys |
| `pr_comments_enabled` | bool | `true` | Post deployment URL on PRs |
| `preview_deployment_setting` | string | `"all"` | `"all"`, `"none"`, or `"custom"` |
| `preview_branch_includes` | list(string) | — | When setting is `"custom"`, branches to include |
| `preview_branch_excludes` | list(string) | — | Branches to exclude from previews |

---

## build_config options

| Option | Type | Notes |
|---|---|---|
| `build_command` | string | Empty string = no build. e.g. `"npm run build"` |
| `destination_dir` | string | Output directory. `/` = repo root. e.g. `"dist"` |
| `root_dir` | string | Monorepo subdirectory to use as project root |
| `build_caching` | bool | Cache build dependencies between runs |
| `web_analytics_tag` | string | Cloudflare Web Analytics dataset tag |
| `web_analytics_token` | string | Auth token for Web Analytics |

---

## deployment_configs (Pages Functions)

If the site uses **Cloudflare Pages Functions** (server-side Workers), add a `deployment_configs` block. Both `preview` and `production` sub-blocks accept:

| Option | Notes |
|---|---|
| `environment_variables` | `map(string)` — runtime env vars |
| `secrets` | `map(string)` — sensitive env vars (encrypted at rest) |
| `kv_namespaces` | `map(string)` — Workers KV bindings |
| `d1_databases` | `map(string)` — D1 SQLite bindings |
| `r2_buckets` | `map(string)` — R2 object storage bindings |
| `durable_object_namespaces` | `map(string)` — Durable Object bindings |
| `service_binding` | Block — call another Worker from this Pages Function |
| `compatibility_date` | Pin Workers runtime version |
| `compatibility_flags` | Enable specific runtime features |
| `usage_model` | `"bundled"`, `"unbound"`, or `"standard"` |
| `fail_open` | Serve static site even if Function crashes |
| `placement` | Smart Placement mode hint |

Static sites with no Functions do not need `deployment_configs`.

---

## Computed attributes

| Attribute | Value |
|---|---|
| `cloudflare_pages_project.<name>.subdomain` | Full `<project>.pages.dev` hostname |
| `cloudflare_pages_project.<name>.domains` | List of attached custom domains |
| `cloudflare_pages_project.<name>.created_on` | Creation timestamp |
