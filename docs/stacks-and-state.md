# Stacks and State

GCS bucket: `gpo-tf-state-data`

| Stack | GCS prefix |
|---|---|
| `tf/bootstrap/prod` | `prod/bootstrap` |
| `tf/bootstrap/stage` | `stage/bootstrap` |
| `tf/infra/singletons` | `infra/singletons` |
| `tf/infra/prod` | `prod/infra` |
| `tf/infra/stage` | `stage/infra` |
| `tf/app/prod` | `prod/app` |
| `tf/app/stage` | `stage/app` |

Dependency order: `bootstrap` → `infra` → `app`. Singletons have no dependencies.

## Remote state pattern

`app` reads from `infra`, `infra` reads from `bootstrap` — both via `data.terraform_remote_state`. See `tf/app/prod/remote_state.tf` and `tf/infra/prod/remote_state.tf` for the exact config.

## tofu-all

Repo root has a `tofu-all` helper script to run a command across all stacks at once.
