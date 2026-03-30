# App Layer

Relevant stacks: `tf/app/prod/`, `tf/app/stage/`
Relevant modules: `tf/modules/app/`

---

## Overview

The app layer manages per-application cloud resources: DNS records, GCP service accounts, secret access grants, and external integrations. It does **not** manage Kubernetes resources directly — those live in separate manifests.

The app layer reads zone IDs and the GKE ingress IP from the infra stack via remote state, then passes them into app modules.

**Always apply with `-parallelism=1`** to avoid GCP API rate limits.

---

## Modules in use

| Module | What it creates |
|---|---|
| `argocd` | DNS A record for `argocd.<zone>` |
| `grassroots` | DNS A record for `grassroots.<zone>` |
| `superset` | DNS A record for `superset.<zone>` |
| `cert_manager` | Cloudflare API token (DNS-01 challenges) + GCP Secret Manager secret |
| `external_secrets` | GCP service account + Secret Manager access grants |
| `legacy_logging` | AWS IAM user + CloudWatch policy for DigitalOcean monitoring |
| `bi_dashboards` | BigQuery dataset + 40 batches of CiviCRM → BigQuery data transfer jobs |
| `drupal` | DigitalOcean Spaces bucket for Drupal file storage |

---

## How modules are wired in main.tf

```hcl
# tf/app/prod/main.tf (simplified)
module "grassroots" {
  source = "../../modules/app/grassroots"

  environment          = local.environment
  ingress_ip_address   = data.terraform_remote_state.infra.outputs.gke_ingress_ip
  cloudflare_zone      = data.terraform_remote_state.infra.outputs.cloudflare_zone_gpo_tools
}
```

The `cloudflare_zone` object shape is `{ id = string, zone = string }`. All app modules that create DNS records expect this variable.

---

## Adding a new application

### 1. Create the module

Create a new directory under `tf/modules/app/my-app/`. At minimum:

**`main.tf`** — the DNS record:
```hcl
locals {
  hostname = "my-app.${var.cloudflare_zone.zone}"
}

resource "cloudflare_record" "my_app" {
  zone_id = var.cloudflare_zone.id
  name    = local.hostname
  content = var.ingress_ip_address
  type    = "A"
  ttl     = 1
  proxied = true
}
```

**`variables.tf`**:
```hcl
variable "cloudflare_zone" {
  type        = object({ id = string, zone = string })
  description = "The Cloudflare zone on which to create DNS records."
}

variable "ingress_ip_address" {
  type        = string
  description = "GKE ingress IP address."
}

variable "environment" {
  type        = string
  validation {
    condition     = contains(["prod", "stage"], var.environment)
    error_message = "Must be prod or stage."
  }
}
```

**`outputs.tf`**:
```hcl
output "hostname" {
  value = local.hostname
}
```

**`tofu.tf`** (if using Cloudflare provider):
```hcl
terraform {
  required_providers {
    cloudflare = { source = "cloudflare/cloudflare" }
  }
}
```

### 2. Instantiate in app/prod and app/stage

In `tf/app/prod/main.tf` and `tf/app/stage/main.tf`:
```hcl
module "my_app" {
  source = "../../modules/app/my-app"

  environment        = local.environment
  ingress_ip_address = data.terraform_remote_state.infra.outputs.gke_ingress_ip
  cloudflare_zone    = data.terraform_remote_state.infra.outputs.cloudflare_zone_gpo_tools
}
```

### 3. Add outputs if K8s needs them

In `tf/app/prod/outputs.tf`, export anything K8s manifests need (hostname, service account emails, etc.):
```hcl
output "my-app" {
  value = {
    hostname = module.my_app.hostname
  }
}
```

---

## cert_manager module

Creates a scoped Cloudflare API token for DNS-01 ACME challenges, then stores it in GCP Secret Manager so cert-manager running in GKE can access it via External Secrets.

Inputs: `cloudflare_zone`, `cloudflare_account_id`, `environment`
Output: `gsm_secret_name`

---

## external_secrets module

Creates a GCP service account (`external-secrets`) and grants it `roles/secretmanager.secretAccessor` on specific secrets. Also binds Workload Identity so the K8s `external-secrets/external-secrets` service account can impersonate it without a key file.

To grant access to additional secrets, pass them via the `secrets` variable:
```hcl
module "external_secrets" {
  source  = "../../modules/app/external_secrets"
  secrets = ["my-new-secret-name"]
}
```

Note: `superset-config`, `superset-env`, and `superset-postgres-db` are hardcoded in the module as always-required.

---

## bi_dashboards module

Transfers CiviCRM MySQL tables to BigQuery for analytics. Creates:
- BigQuery dataset `civicrm_tables`
- 40 `google_bigquery_data_transfer_config` resources, each moving 5 tables
- Transfers scheduled at 1-minute intervals (00:00 through 00:39) to avoid rate limiting

This module is compute-heavy at plan/apply time. Runs in `tf/app/prod/` only (not stage).
