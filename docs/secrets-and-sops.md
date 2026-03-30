# Secrets and SOPS

## Files

| File | Scope |
|---|---|
| `secrets.env` | All stacks |
| `secrets.prod.env` | Production only |
| `secrets.stage.env` | Stage only |

All at repo root, SOPS-encrypted, safe to commit.

## Usage in Terraform

```hcl
data "sops_file" "secrets" {
  source_file = "../../secrets.env"  # path relative to the .tf file
}
# Access: data.sops_file.secrets.data["key_name"]
```

## Known keys (secrets.env)

`cloudflare_api_key`, `cloudflare_account_id`, `github_ssh_user`, `github_ssh_host_stage`, `github_ssh_host_prod`, `github_ssh_private_key`, `github_ssh_public_key`

## KMS keys

Created by `tf/modules/bootstrap/sops/`. One AWS KMS key + one GCP KMS key ring/crypto key per environment (`sops-prod`, `sops-stage`). Both have `prevent_destroy = true`.
