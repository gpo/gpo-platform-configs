# GitHub Repository Management

Relevant stack: `tf/infra/singletons/`

---

## Overview

GitHub repository configuration is managed in `tf/infra/singletons/`:

| File | What it manages |
|---|---|
| `github_repos.tf` | Repository creation and settings |
| `github_labels.tf` | Issue labels (standard + custom per repo) |
| `github_secrets.tf` | GitHub Actions secrets |

Provider: `integrations/github` v6.4.0, configured with `owner = "gpo"`.

---

## Existing repositories

| Repo | Visibility | Description |
|---|---|---|
| `secure-gpo-ca` | private | Drupal/CiviCRM site |
| `gpo-ca` | private | Main GPO website |
| `gpo-platform-configs` | public | This repo |
| `gpo-it` | private | Google Workspace config |
| `civicrm-api` | public | JS/TS CiviCRM client |
| `public` | public | READMEs and roadmap |
| `open-walk-sheets` | public | Walk sheets with wiki |
| `.github` | public | Org-wide settings |
| `migrate_bitbucket_to_github` | public | Migration tooling |
| `CDNTaxReceipts` | public | Tax receipt tooling |

---

## Adding a new repository

Add to `tf/infra/singletons/github_repos.tf`. Pattern from existing repos:

```hcl
resource "github_repository" "my_new_repo" {
  name        = "my-new-repo"
  description = "What this repo is for"
  visibility  = "private"  # or "public"

  # Branch settings
  auto_init          = true
  default_branch     = "main"  # set via github_branch_default below

  # Merge strategy (choose what fits the team workflow)
  allow_merge_commit     = false
  allow_squash_merge     = true
  allow_rebase_merge     = false
  delete_branch_on_merge = true

  vulnerability_alerts = true
}

resource "github_branch_default" "my_new_repo" {
  repository = github_repository.my_new_repo.name
  branch     = "main"
}
```

---

## Adding issue labels

Labels are managed via the `github_default_labels` module in `tf/infra/singletons/github_labels.tf`.

**To apply standard labels only:**
```hcl
module "my_repo_labels" {
  source     = "../../modules/infra/github_default_labels"
  repository = github_repository.my_new_repo.name
  labels     = []
}
```

**To add custom labels on top of the standard set:**
```hcl
module "my_repo_labels" {
  source     = "../../modules/infra/github_default_labels"
  repository = github_repository.my_new_repo.name
  labels = [
    { name = "CiviCRM",  description = "CiviCRM related", color = "e4e669" },
    { name = "Drupal",   description = "Drupal related",  color = "1d76db" },
  ]
}
```

Standard labels created by the module include: Epic, enhancement, performance, bug, documentation, question, invalid, wontfix, duplicate, help wanted, good first issue, volunteer.

---

## Adding GitHub Actions secrets

Secrets are defined in `tf/infra/singletons/github_secrets.tf`. Values come from the SOPS-encrypted `secrets.env` file.

```hcl
resource "github_actions_secret" "my_repo_my_secret" {
  repository      = github_repository.my_new_repo.name
  secret_name     = "MY_SECRET_NAME"
  plaintext_value = data.sops_file.secrets.data["my_secret_key"]
}
```

The SOPS key name (`my_secret_key`) must exist in `secrets.env`. See [docs/secrets-and-sops.md](secrets-and-sops.md) for how to add a new secret.

---

## Secrets currently managed

Both `gpo-ca` and `secure-gpo-ca` have these Actions secrets set:

- `SSH_USER`
- `SSH_HOST_STAGE`
- `SSH_HOST_PROD`
- `SSH_PRIVATE_KEY`
- `SSH_PUBLIC_KEY`
