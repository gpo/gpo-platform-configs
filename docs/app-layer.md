# App Layer

Stacks: `tf/app/prod/`, `tf/app/stage/`
Modules: `tf/modules/app/`

## Modules

| Module | Creates |
|---|---|
| `argocd` | DNS A record `argocd.<zone>` |
| `grassroots` | DNS A record `grassroots.<zone>` |
| `superset` | DNS A record `superset.<zone>` |
| `cert_manager` | Scoped Cloudflare API token (DNS-01) + GCP Secret Manager secret |
| `external_secrets` | GCP service account + Secret Manager access grants + Workload Identity binding |
| `legacy_logging` | AWS IAM user `digital-ocean-monitoring` + CloudWatch policy |
| `bi_dashboards` | BigQuery dataset `civicrm_tables` + 40 data transfer configs (CiviCRM → BQ) |
| `drupal` | DigitalOcean Spaces bucket (`drupal` / `drupal-stage`) |

## Wiring

All modules receive `cloudflare_zone = { id, zone }` and `ingress_ip_address` from infra remote state. See `tf/app/prod/main.tf` for how modules are instantiated and `tf/app/prod/outputs.tf` for what gets exported for K8s consumption.

## Adding a new app module

1. Create `tf/modules/app/<name>/` — follow any existing module as a pattern
2. Instantiate in `tf/app/prod/main.tf` and `tf/app/stage/main.tf`
3. Export needed values (hostname, service account, etc.) in `tf/app/{prod,stage}/outputs.tf`
