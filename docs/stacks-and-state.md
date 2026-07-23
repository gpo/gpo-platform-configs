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

## Plan and apply

Always save the plan and apply that exact file, rather than running a bare `tofu apply` (which re-plans on its own and can apply something other than what was reviewed):

```bash
tofu plan -out=plan
tofu apply plan
```

Before applying, check the plan for changes unrelated to what you're working on — drift in other resources (e.g. a setting that was changed outside Terraform) will show up in the same plan. Apply it separately or fix the config to match reality instead of bundling it into an unrelated change.
