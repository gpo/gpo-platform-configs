# IAM Users

## AWS — `tf/modules/bootstrap/iam_users/`

Defined in `tf/bootstrap/{prod,stage}/locals.tf`:

```
iam_admin_users = ["rsalmond", "ianedington"]          # prod + stage
iam_admin_users = ["rsalmond", "ianedington", "verdird", "mattw"]  # stage also has these
iam_eks_users   = ["pnovikov"]                          # stage only
```

- Admin users → `admin` group → `AdministratorAccess`
- EKS users → `eks` group → scoped read/ECR/KMS access (stage only)

Initial passwords retrieved via `tofu output -json | jq '.user_creds.value'` after first apply.

## GCP developer access — stage only

Module: `tf/modules/bootstrap/gcp_iam_devs_stage/`
Defined in: `tf/bootstrap/stage/locals.tf` → `dev_users = [...]`

Grants `roles/artifactregistry.writer` + `roles/container.developer`. Add an email to `dev_users` and apply.

## DigitalOcean monitoring user

Created by `tf/modules/app/legacy_logging/` — IAM user `digital-ocean-monitoring` with a CloudWatch write policy. Not in the `iam_users` module.
