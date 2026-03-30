# Secrets and SOPS

---

## Overview

All secrets are encrypted with [SOPS](https://github.com/getsops/sops) using KMS keys (both AWS and GCP). Encrypted files are committed to the repository. Plain text secrets are **never** committed.

---

## Secret files

| File | Scope |
|---|---|
| `secrets.env` | Shared across all stacks and environments |
| `secrets.prod.env` | Production-only secrets |
| `secrets.stage.env` | Stage-only secrets |

All files live at the **repository root**.

---

## How secrets are consumed in Terraform

Each stack declares a SOPS data source pointing at the relevant secrets file:

```hcl
data "sops_file" "secrets" {
  source_file = "../../secrets.env"   # path relative to the .tf file
}
```

Values are accessed by key:
```hcl
api_key    = data.sops_file.secrets.data["cloudflare_api_key"]
account_id = data.sops_file.secrets.data["cloudflare_account_id"]
```

Stacks that need both shared and environment-specific secrets declare two data sources:
```hcl
data "sops_file" "secrets"      { source_file = "../../secrets.env" }
data "sops_file" "secrets_prod" { source_file = "../../secrets.prod.env" }
```

---

## Known secret keys (shared secrets.env)

| Key | Used by |
|---|---|
| `cloudflare_api_key` | All Cloudflare resources |
| `cloudflare_account_id` | Cloudflare zone creation, Pages projects |
| `github_ssh_user` | GitHub Actions secrets |
| `github_ssh_host_stage` | GitHub Actions secrets |
| `github_ssh_host_prod` | GitHub Actions secrets |
| `github_ssh_private_key` | GitHub Actions secrets |
| `github_ssh_public_key` | GitHub Actions secrets |

---

## Adding a new secret

1. **Decrypt** the relevant secrets file:
   ```bash
   sops --decrypt secrets.env > secrets.env.dec
   ```
2. **Add** your new key/value to the decrypted file.
3. **Re-encrypt**:
   ```bash
   sops --encrypt secrets.env.dec > secrets.env
   rm secrets.env.dec
   ```
4. **Reference** it in your Terraform:
   ```hcl
   my_value = data.sops_file.secrets.data["my_new_key"]
   ```
5. Commit the updated (encrypted) `secrets.env`.

---

## KMS keys

SOPS uses both AWS KMS and GCP KMS keys for encryption (multi-key redundancy). Keys are created by the `sops` bootstrap module:

- **AWS KMS**: one key per environment, created in `tf/modules/bootstrap/sops/main.tf`
- **GCP KMS**: key ring `sops-{environment}` with crypto key `sops-{environment}`, created in `tf/modules/bootstrap/sops/gcp.tf`
  - Lifecycle: `prevent_destroy = true` — these keys cannot be accidentally deleted via Terraform

---

## SOPS provider

The `carlpett/sops` provider v0.7.2 is declared in every stack's `tofu.tf`:

```hcl
sops = {
  source  = "carlpett/sops"
  version = "0.7.2"
}
```

No provider configuration block is needed — it reads from your current AWS/GCP credentials automatically.

---

## Rotating secrets

1. Update the value in the secrets file (decrypt → edit → re-encrypt, as above).
2. Run `tofu plan` in the affected stack — Terraform will detect the changed value.
3. Run `tofu apply` to push the new value to any resources that reference it (e.g. GitHub Actions secrets).
