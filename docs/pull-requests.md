# Writing and Merging PRs

**Stage runs the same code as prod, and stage runs it first.** Everything here follows from that.

## Terraform

A change ships as two PRs:

**stage PR → apply stage → merge → prod PR → apply prod → merge**

The apply happens while the PR is open; merging records that it worked, so `main` describes what is running.

- Shared logic goes in `tf/modules/`. The stack files are a module call plus environment variables, nothing more.
- The prod PR must not change the module. If it needs to, stage never ran what prod is about to run — go back to a stage PR.
- Compare the prod plan to the stage plan. Same resource shape; only names, IDs, and counts differ. A shape mismatch means the environments have diverged, and that is the bug.
- Put the plan and apply output in the PR body. If unrelated drift shows up in the plan, it gets its own PR.
- Leaving the prod PR unopened is how prod falls behind. If prod is intentionally not getting the change, say so in the stage PR.

### No stage tier

`tf/infra/singletons/` and `tf/bootstrap/` apply straight to live production. One PR: plan in the body, **a human approves before the apply**, then apply and merge. An agent never applies these on its own initiative. Keep them small.

## Kubernetes

Same two PRs, stage then prod, but ArgoCD syncs from `main` — so merging is deploying, and verification comes after the merge instead of before it.

- Change the values or template, never a file under `rendered/`. Re-render and commit the result in the same PR: the rendered diff is the review.
- Merge stage, wait for the sync, confirm the workload is healthy, then open the prod PR.
- Bump versions in stage first, then bump prod to the version stage has been running.

## Also

- Docs ship in the same PR as the change they describe. Decisions with rejected alternatives go in `DECISION_LOG.md`.
- Stop and ask a human before destructive plans: resource replacement or deletion, `tofu state rm`/`mv`/`import`, KMS keys, state buckets, `gpo.ca` DNS.
