# IAM Users

Relevant stack: `tf/bootstrap/{prod,stage}/`
Relevant module: `tf/modules/bootstrap/iam_users/`

---

## AWS IAM users

### Existing users

Users are defined in `tf/bootstrap/{prod,stage}/locals.tf`:

```hcl
# prod and stage both have:
iam_admin_users = ["rsalmond", "ianedington"]

# stage also has:
iam_admin_users = ["rsalmond", "ianedington", "verdird", "mattw"]
iam_eks_users   = ["pnovikov"]
```

### User types

| Type | Group | Permissions |
|---|---|---|
| `iam_admin_users` | `admin` | `AdministratorAccess` |
| `iam_eks_users` | `eks` | `ReadOnlyAccess` + ECR push + KMS decrypt (stage only) |

### Adding a new admin user

1. Add the username to `iam_admin_users` in `tf/bootstrap/{prod,stage}/locals.tf`
2. Run `tofu apply` in `tf/bootstrap/prod/` and/or `tf/bootstrap/stage/`
3. Retrieve the temporary password:
   ```bash
   tofu output -json | jq '.user_creds.value'
   ```
   The user must change their password on first login.

### Adding a new EKS user

Add the username to `iam_eks_users` in the relevant `locals.tf`. EKS users are also granted EKS access entries in the `eks` module — their ARN is passed from bootstrap outputs through to the infra stack automatically via remote state.

---

## GCP developer access (stage only)

Module: `tf/modules/bootstrap/gcp_iam_devs_stage/`

Stage supports granting GCP access to individual developer email addresses. This is defined in `tf/bootstrap/stage/main.tf`:

```hcl
module "gcp_iam_dev_<username>" {
  source  = "../../modules/bootstrap/gcp_iam_devs_stage"
  project = module.apis.project  # or relevant project
  user    = "developer@example.com"
}
```

The module grants:
- `roles/artifactregistry.writer` — push Docker images to GAR
- `roles/container.developer` — access GKE clusters (no create/delete)

### Adding a new developer (stage)

1. Add their email to `local.dev_users` in `tf/bootstrap/stage/locals.tf`:
   ```hcl
   dev_users = ["existing@example.com", "newdev@example.com"]
   ```
2. The `main.tf` iterates over this list with `for_each = toset(local.dev_users)` — no other changes needed.
3. Run `tofu apply` in `tf/bootstrap/stage/`.

---

## DigitalOcean monitoring user

There is one additional IAM user not managed through the `iam_users` module: `digital-ocean-monitoring`.

This is created by the `legacy_logging` app module (`tf/modules/app/legacy_logging/`) and is used for shipping DigitalOcean logs to AWS CloudWatch. It has a custom IAM policy allowing CloudWatch and CloudWatch Logs write actions.

This user is instantiated in `tf/app/{prod,stage}/main.tf` and its access key is output (sensitive) for use in the DigitalOcean monitoring configuration.
