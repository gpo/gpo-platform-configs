# Bootstrap

Stacks: `tf/bootstrap/prod/`, `tf/bootstrap/stage/`
Modules: `tf/modules/bootstrap/`

Run once per environment. Rarely touched after initial setup.

## What it creates

- **`iam_users`** — AWS IAM admin + EKS users, groups, login profiles
- **`state_bucket`** — S3 bucket (versioned) + DynamoDB lock table
- **`sops`** — AWS KMS key + GCP KMS key ring/crypto key for secret encryption (`prevent_destroy = true`)
- **`apis`** — enables `secretmanager.googleapis.com`
- **`gcp_iam_devs_stage`** (stage only) — per-developer GCP access, iterated from `local.dev_users`

## GCP projects created

`gpo-eng-prod` + `gpo-data-prod` (prod) · `gpo-eng-stage` + `calm-segment-466901-e4` (stage)
Org: `267619224561` · Billing: `019C4D-E56387-A59CAF`

## First-time apply order

1. Manually create GCS bucket `gpo-tf-state-data`
2. Apply `tf/bootstrap/{prod,stage}/`
3. Apply `tf/infra/{prod,stage}/`
4. Apply `tf/app/{prod,stage}/`

`tf/infra/singletons/` can be applied at any point.
