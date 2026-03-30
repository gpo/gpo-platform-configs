# GKE and GCP

Modules: `tf/modules/infra/gcp/gke/`, `tf/modules/infra/gcp/gar/`
Instantiated in: `tf/infra/prod/main.tf`, `tf/infra/stage/main.tf`

## GCP projects (per environment)

| Project ID | Purpose |
|---|---|
| `gpo-eng-prod` / `gpo-eng-stage` | GKE cluster, Artifact Registry |
| `gpo-data-prod` / `calm-segment-466901-e4` | BigQuery, data infra |

Org: `267619224561` · Billing: `019C4D-E56387-A59CAF`
Project IDs come from bootstrap remote state — never hardcoded.

## Region / zone

`northamerica-northeast2` (Toronto), zone `northamerica-northeast2-a`. Used for all GCP resources.

## What the modules create

**gke**: VPC, node service account, GKE cluster (Gateway API enabled, Workload Identity enabled), global static IP `gke-ingress-ip`
**gar**: Docker registry `gpo` at `northamerica-northeast2-docker.pkg.dev/<project>/gpo`

## Key outputs (consumed by app layer via remote state)

- `gke_ingress_ip` — static IP used for all app DNS A records
- `image_repository_uri` — GAR registry URI
- `cloudflare_zone_gpo_tools` — `{ id, zone }` passed to app modules
