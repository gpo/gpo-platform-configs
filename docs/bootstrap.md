# Bootstrap

Relevant stacks: `tf/bootstrap/prod/`, `tf/bootstrap/stage/`
Relevant modules: `tf/modules/bootstrap/`

---

## Overview

The bootstrap stacks are run **once** when setting up a new environment. They create the foundational resources that all other stacks depend on:

- AWS IAM users and groups
- S3 bucket and DynamoDB table for Terraform state
- SOPS encryption keys (AWS KMS + GCP KMS)
- GCP projects
- GCP API enablement

> **Do not run bootstrap stacks regularly.** They are designed for initial setup only. Day-to-day changes go in `infra/` or `app/`.

---

## What each module creates

### `iam_users`

- AWS IAM users for `iam_admin_users` list → `admin` group with `AdministratorAccess`
- AWS IAM users for `iam_eks_users` list → `eks` group with scoped access
- Login profiles with forced password change on first login
- See [docs/iam-users.md](iam-users.md) for how to add users

### `state_bucket`

- S3 bucket for Terraform remote state (versioning + AES256 encryption)
- DynamoDB table `terraform-state-locks` for state locking
- `force_destroy = true` on the bucket (intentional for bootstrap scenarios)

### `sops`

- AWS KMS key for SOPS encryption
- GCP KMS key ring `sops-{environment}` + crypto key `sops-{environment}`
- Both keys have `lifecycle { prevent_destroy = true }` — they **cannot** be deleted via Terraform
- See [docs/secrets-and-sops.md](secrets-and-sops.md) for how secrets work

### `apis`

- Enables `secretmanager.googleapis.com` on the bootstrap GCP project

### `gcp_iam_devs_stage` (stage only)

- Per-developer GCP IAM grants (GAR write, GKE developer)
- One module instance per email in `local.dev_users`
- See [docs/iam-users.md](iam-users.md) for how to add developers

---

## GCP projects

Two GCP projects are created per environment in `tf/bootstrap/{prod,stage}/gcp_projects.tf`:

| Project resource | Project ID | Purpose |
|---|---|---|
| `google_project.gpo_data` | `gpo-data-prod` / stage equivalent | Data infrastructure |
| `google_project.gpo_eng` | `gpo-eng-prod` / `gpo-eng-stage` | Engineering (GKE, GAR) |

GCP organization: `267619224561`
Billing account: `019C4D-E56387-A59CAF`

Project IDs are exported as outputs and consumed by downstream stacks via remote state.

---

## Bootstrap outputs

Other stacks read these via `data.terraform_remote_state.bootstrap.outputs.*`:

| Output | Type | Used by |
|---|---|---|
| `admin_user_arns` | list(string) | infra/eks module |
| `eks_user_arns` | list(string) | infra/eks module |
| `user_creds` | map (sensitive) | Retrieved manually after first apply |
| `gcp_project_gpo_data` | object | infra providers |
| `gcp_project_gpo_eng` | object | infra providers (GKE, GAR) |
| `gcp_project_bootstrap` | string | sops module |

---

## First-time setup sequence

If bootstrapping a brand new environment:

1. Manually create the GCS bucket `gpo-tf-state-data` (chicken-and-egg: the bucket must exist before Terraform can use it as a backend)
2. Run `tofu apply` in `tf/bootstrap/{prod,stage}/`
3. Retrieve initial user passwords: `tofu output -json | jq '.user_creds.value'`
4. Run `tofu apply` in `tf/infra/{prod,stage}/`
5. Run `tofu apply -parallelism=1` in `tf/app/{prod,stage}/`

`tf/infra/singletons/` can be applied at any point — it has no dependencies on other stacks.

---

## Provider configuration

Bootstrap uses three providers:

```hcl
provider "aws" {
  profile = "gpo-prod"   # or "gpo-stage"
  region  = "ca-central-1"
}

provider "google" {
  project = "gpo-bootstrap-2"  # the pre-existing bootstrap GCP project
}
```

The `sops` provider requires no configuration block — it picks up AWS/GCP credentials from the environment.
