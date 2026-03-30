# GPO Platform Configs — Agent Guide

This repo is the single source of truth for GPO's infrastructure and platform configuration, managed with OpenTofu (Terraform-compatible).

## What this repo manages

- **Cloudflare** — DNS zones, records, Pages projects, redirect rules (gpo.ca, gpotools.ca, gpotoolsstage.ca)
- **GitHub** — Repository creation, branch settings, issue labels, Actions secrets
- **GCP / GKE** — Kubernetes clusters (Toronto), Artifact Registry, GCP projects, service accounts
- **AWS / EKS** — EKS clusters, VPC networking, ECR, IAM users
- **Secrets** — SOPS-encrypted secrets, KMS keys (AWS + GCP)
- **Bootstrap** — One-time account setup (GCP projects, AWS IAM, S3 state buckets)

---

## Stack layout

All Terraform lives under `tf/`. There are four independent stacks, each with its own state file:

```
tf/
├── bootstrap/{prod,stage}/     # One-time account setup — run once, rarely touched
├── infra/{singletons,prod,stage}/  # Clusters, zones, networks — shared infra
├── app/{prod,stage}/           # Per-app resources — DNS, secrets, IAM bindings
└── modules/                    # Reusable modules (never deployed directly)
    ├── app/
    ├── bootstrap/
    └── infra/
```

Stacks are independent. `app` reads outputs from `infra` via `terraform_remote_state`. `infra` reads outputs from `bootstrap` the same way.

**All state is stored in GCS bucket `gpo-tf-state-data`**, organised by path:

| Stack | GCS prefix |
|---|---|
| bootstrap/prod | `prod/bootstrap` |
| bootstrap/stage | `stage/bootstrap` |
| infra/prod | `prod/infra` |
| infra/stage | `stage/infra` |
| infra/singletons | `infra/singletons` |
| app/prod | `prod/app` |
| app/stage | `stage/app` |

---

## Critical rules — read before touching anything

1. **Never run `tofu apply` on `app/` with default parallelism.** GCP rate-limits concurrent API calls. Always use:
   ```
   tofu apply -parallelism=1
   ```
2. **Secrets are SOPS-encrypted.** Never commit plaintext secrets. Source files: `secrets.env` (shared), `secrets.prod.env`, `secrets.stage.env` in the repo root.
3. **Two AWS CLI profiles are required:** `gpo-prod` (account 060795914812) and `gpo-stage` (account 542371827759), both `ca-central-1`.
4. **Singletons are global** — changes to `tf/infra/singletons/` affect live production immediately (gpo.ca DNS, GitHub repos, etc.).
5. **Don't put Kubernetes resources in Terraform** — K8s manifests live separately. TF manages cloud-provider resources only.

---

## Provider versions

| Provider | Version used in `infra/` + singletons | Version used in `app/` |
|---|---|---|
| cloudflare/cloudflare | 4.48.0 | 5.15.0 |
| integrations/github | 6.4.0 | — |
| carlpett/sops | 0.7.2 | 0.7.2 |
| hashicorp/aws | 5.81 | 5.81 |
| hashicorp/google | 7.12.0 | 7.12.0 |
| digitalocean/digitalocean | 2.46.1 | 2.46.1 |

---

## Naming conventions

- Resource names: `snake_case`, qualified with environment where needed (e.g. `cloudflare_record.staging_gpo_ca`)
- Module output objects for Cloudflare zones: `{ id = string, zone = string }`
- DNS record `name` attribute: always the **full FQDN** (e.g. `"staging.gpo.ca"`, not `"staging"`)
- TTL: always `1` when `proxied = true`, otherwise `300`
- Toggle flags: use `locals {}` block, not `variable {}`, so no `-var` flags are needed at apply time

---

## How to apply changes

```bash
cd tf/<stack>/<environment>
tofu init        # first time or after provider changes
tofu plan
tofu apply       # add -parallelism=1 for app/ stacks
```

To apply all stacks at once, use the `tofu-all` helper script in the repo root.

---

## Documentation index

Read only the doc relevant to your task:

| Task | Doc |
|---|---|
| Add or change DNS records / Cloudflare zones | [docs/cloudflare-dns.md](docs/cloudflare-dns.md) |
| Deploy a Cloudflare Pages site | [docs/cloudflare-pages.md](docs/cloudflare-pages.md) |
| Create or configure a GitHub repository | [docs/github-repos.md](docs/github-repos.md) |
| Work with GKE, GCP projects, or Artifact Registry | [docs/gke-and-gcp.md](docs/gke-and-gcp.md) |
| Work with EKS, VPC, or ECR | [docs/aws-eks.md](docs/aws-eks.md) |
| Add or rotate secrets / SOPS | [docs/secrets-and-sops.md](docs/secrets-and-sops.md) |
| Add an IAM user (AWS or GCP) | [docs/iam-users.md](docs/iam-users.md) |
| Understand stack boundaries or remote state wiring | [docs/stacks-and-state.md](docs/stacks-and-state.md) |
| Add a new application to the app layer | [docs/app-layer.md](docs/app-layer.md) |
| Bootstrap a new cloud account | [docs/bootstrap.md](docs/bootstrap.md) |
