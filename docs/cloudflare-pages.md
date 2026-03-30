# Cloudflare Pages

## Existing projects

| Project name | Repo | Domain | File |
|---|---|---|---|
| `1997-gpo-ca` | `gpo/1997` | `1997.gpo.ca` | `tf/infra/singletons/cloudflare_april_fools.tf` |

## Three resources required per project

1. `cloudflare_pages_project` — wires the GitHub repo
2. `cloudflare_record` (CNAME) — points subdomain at `<project>.pages.dev` via the computed `cloudflare_pages_project.<name>.subdomain` attribute
3. `cloudflare_pages_domain` — attaches the custom domain

See `tf/infra/singletons/cloudflare_april_fools.tf` for the full working pattern.

## Pre-requisite

The Cloudflare Pages → GitHub OAuth connection must be authorised manually in the Cloudflare dashboard before first apply (Workers & Pages → Settings → Integrations → GitHub). Terraform cannot create it.
