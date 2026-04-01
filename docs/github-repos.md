# GitHub Repos

File: `tf/infra/singletons/github_repos.tf`
Labels: `tf/infra/singletons/github_labels.tf`
Secrets: `tf/infra/singletons/github_secrets.tf`

## Repos managed

| Repo | Visibility |
|---|---|
| `secure-gpo-ca` | private |
| `gpo-ca` | private |
| `gpo-platform-configs` | public |
| `gpo-it` | private |
| `civicrm-api` | public |
| `public` | public |
| `open-walk-sheets` | public |
| `.github` | public |
| `migrate_bitbucket_to_github` | public |
| `CDNTaxReceipts` | public |

## Actions secrets

Both `gpo-ca` and `secure-gpo-ca` have: `SSH_USER`, `SSH_HOST_STAGE`, `SSH_HOST_PROD`, `SSH_PRIVATE_KEY`, `SSH_PUBLIC_KEY` — all sourced from SOPS `secrets.env`.

## Labels

Standard labels applied via `tf/modules/infra/github_default_labels`. Custom labels (e.g. CiviCRM, Drupal) added per-repo as overrides.
