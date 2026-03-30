# GKE and GCP Infrastructure

Relevant stacks: `tf/infra/prod/`, `tf/infra/stage/`
Relevant modules: `tf/modules/infra/gcp/gke/`, `tf/modules/infra/gcp/gar/`

---

## GCP projects

Two GCP projects per environment, created in the `bootstrap` stack:

| Project | Environment | Purpose |
|---|---|---|
| `gpo-data-prod` | prod | Data infrastructure (BigQuery, etc.) |
| `gpo-eng-prod` | prod | Engineering infrastructure (GKE, GAR) |
| `calm-segment-466901-e4` | stage | Data (stage) |
| `gpo-eng-stage` | stage | Engineering (stage) |

GCP org ID: `267619224561`
GCP billing account: `019C4D-E56387-A59CAF`

---

## GKE cluster

One GKE cluster per environment, defined in `tf/infra/{prod,stage}/main.tf` via the `gke` module:

```
tf/modules/infra/gcp/gke/
```

### What the module creates

- GCP VPC network: `gpo-prod` / `gpo-stage` (auto-create subnetworks)
- GCP service account: `gke-gpo-prod` / `gke-gpo-stage`
- GKE cluster (`google_container_cluster`):
  - Initial node count: 3
  - Gateway API: `CHANNEL_STANDARD` (no separate ingress controller needed)
  - Workload Identity enabled
  - GKE Metadata Server enabled
  - Deletion protection: off
- Global static external IP: `gke-ingress-ip` (used for DNS A records in the app layer)

### Key design decisions

- **Gateway API** is used instead of a separately-deployed ingress controller (see `DECISION_LOG.md`)
- **Workload Identity** is enabled so K8s service accounts can authenticate to GCP APIs without key files
- The static IP is reserved at the infra layer and passed as an output to the app layer

### Module inputs

```hcl
module "gke" {
  source      = "../../modules/infra/gcp/gke"
  name        = local.name         # "gpo"
  environment = local.environment  # "prod" or "stage"
  location    = local.zone_toronto # "northamerica-northeast2-a"
}
```

### Output used by app layer

```hcl
output "gke_ingress_ip" {
  value = module.gke.ingress_ip
}
```

This IP is read by `tf/app/{prod,stage}/` via remote state and passed into app modules as `ingress_ip_address`.

---

## Artifact Registry (GAR)

One Docker registry per environment, defined in `tf/infra/{prod,stage}/main.tf` via the `gar` module:

```
tf/modules/infra/gcp/gar/
```

### What the module creates

- Enables `artifactregistry.googleapis.com`
- Creates a Docker repository named `gpo` in `northamerica-northeast2` (Toronto)
- Full URI: `northamerica-northeast2-docker.pkg.dev/<project>/gpo`

### Output used by app layer

```hcl
output "image_repository_uri" {
  value = module.gar.repository_uri
}
```

---

## Region and zone

| Variable | Value |
|---|---|
| `region_toronto` | `northamerica-northeast2` |
| `zone_toronto` | `northamerica-northeast2-a` |

All GCP resources are deployed to Toronto. Stage uses the same region.

---

## GCP provider configuration

The `infra/prod` stack uses two Google provider aliases:

```hcl
provider "google" {
  alias   = "gpo_eng"
  project = data.terraform_remote_state.bootstrap.outputs.gcp_project_gpo_eng.project_id
}
```

The project ID is read from bootstrap remote state — never hardcoded.

---

## IAM for GKE nodes

The GKE node service account is granted:
- `roles/artifactregistry.reader` — pull images from GAR
- `roles/container.defaultNodeServiceAccount` — standard GKE node permissions

These are defined in `tf/modules/infra/gcp/gke/iam.tf`.

---

## Enabling new GCP APIs

APIs are enabled in `tf/modules/infra/gcp/gke/apis.tf` (for the GKE module) and `tf/modules/bootstrap/apis/main.tf` (for bootstrap). To enable an additional API, add a `google_project_service` resource with `disable_on_destroy = false`.
