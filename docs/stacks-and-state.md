# Stacks and State

---

## What is a stack?

A "stack" is an independently deployable Terraform root module with its own state file. Changes to one stack do not affect other stacks until they are explicitly applied. This repo has seven stacks:

| Stack directory | GCS state prefix | Deployed how often |
|---|---|---|
| `tf/bootstrap/prod` | `prod/bootstrap` | Rarely (new accounts, new users) |
| `tf/bootstrap/stage` | `stage/bootstrap` | Rarely |
| `tf/infra/singletons` | `infra/singletons` | Occasionally (DNS, GitHub repos) |
| `tf/infra/prod` | `prod/infra` | Occasionally (cluster changes) |
| `tf/infra/stage` | `stage/infra` | Occasionally |
| `tf/app/prod` | `prod/app` | Regularly (new apps, config changes) |
| `tf/app/stage` | `stage/app` | Regularly |

All state is stored in GCS bucket **`gpo-tf-state-data`**.

---

## Dependency chain

Stacks depend on each other in one direction only:

```
bootstrap → infra → app
```

- `infra` reads outputs from `bootstrap` via remote state
- `app` reads outputs from `infra` via remote state
- `singletons` is independent (no remote state dependencies)

**You must apply lower layers before higher layers** when setting up from scratch. For day-to-day changes this is rarely relevant — most changes are isolated within one stack.

---

## How remote state references work

Outputs from one stack are consumed by another using `terraform_remote_state`:

```hcl
# In tf/app/prod/remote_state.tf
data "terraform_remote_state" "infra" {
  backend = "gcs"
  config = {
    bucket = "gpo-tf-state-data"
    prefix = "prod/infra"
  }
}
```

Then used as:
```hcl
cloudflare_zone = data.terraform_remote_state.infra.outputs.cloudflare_zone_gpo_tools
ingress_ip      = data.terraform_remote_state.infra.outputs.gke_ingress_ip
```

### What infra/prod exports

| Output | Type | Used by |
|---|---|---|
| `cloudflare_zone_gpo_tools` | `{ id, zone }` | App modules for DNS records |
| `gke_ingress_ip` | string | App modules for DNS A records |
| `image_repository_uri` | string | App layer for container image paths |

### What bootstrap/prod exports

| Output | Used by |
|---|---|
| `admin_user_arns` | infra (EKS access entries) |
| `eks_user_arns` | infra (EKS access entries) |
| `gcp_project_gpo_eng` | infra (GKE provider project) |
| `gcp_project_gpo_data` | infra (BigQuery, etc.) |
| `gcp_project_bootstrap` | infra (bootstrap project ID) |

---

## GCS backend configuration

Every stack declares a backend in its `tofu.tf`:

```hcl
terraform {
  backend "gcs" {
    bucket = "gpo-tf-state-data"
    prefix = "prod/infra"   # unique per stack
  }
}
```

The GCS bucket was created by the `state_bucket` bootstrap module. There is no DynamoDB-style locking for GCS — GCS uses native object locking.

> **Note:** A DynamoDB table `terraform-state-locks` also exists (created by `state_bucket`) but is used only for the AWS backend, not GCS.

---

## Running a stack

```bash
cd tf/<layer>/<environment>
tofu init     # needed after provider changes or first checkout
tofu plan
tofu apply
```

**Critical:** The `app/` stacks must be run with reduced parallelism to avoid GCP API rate limits:
```bash
tofu apply -parallelism=1
```

---

## Running all stacks

Use the `tofu-all` helper at the repo root to run a command across every stack:
```bash
./tofu-all plan
./tofu-all apply -parallelism=1
```

---

## Singletons vs per-environment stacks

`tf/infra/singletons/` is intentionally not split into prod/stage. Resources here (gpo.ca DNS, GitHub repos) exist once globally. There is no staging equivalent — be careful, changes apply immediately to production systems.
