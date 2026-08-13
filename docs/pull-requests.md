# Writing and Merging PRs

Rules for how change reaches production in this repo. Written for AI agents, and binding on humans too.

The core idea: **stage runs the same code as prod, and stage runs it first.** Everything below follows from that.

## The universal rules

1. **One PR, one change.** If a plan or diff contains an unrelated fix, split it into its own PR. Drift you discover while working is a separate PR, not a passenger.
2. **Never push to `main`.** Branch, PR, merge. This is enforced by permissions, not by trust.
3. **Never merge a PR whose change has not been applied to stage** (or, where there is no stage, applied and verified by a human). A merged PR must describe reality, not intent.
4. **Shared code lives in `tf/modules/` or a shared template.** Stage and prod must differ only in variables and values, never in logic. If you are about to write the same resource twice with different names, write a module instead.
5. **Say what you applied.** Every PR body records what was applied, where, and what the output was. A reviewer must never have to ask "did this run?"
6. **Stop and ask before anything destructive.** Resource deletion or replacement, state surgery (`tofu state rm`/`mv`/`import`), touching KMS keys, state buckets, or DNS for `gpo.ca`. Post the relevant plan lines and wait for a human.

## Terraform (`tf/`)

Change order is always: **stage → PR → apply stage → merge → apply prod.**

1. Write the change so both environments share it. New logic goes in `tf/modules/<layer>/<name>/`; the stack files under `tf/{bootstrap,infra,app}/{stage,prod}/` should be little more than a module call plus environment-specific variables.
2. Wire the module into **stage** and **prod** in the same PR. Stage-only code is a temporary state that hides drift; the difference between the two is the variables passed in, nothing else.
3. Plan and apply **stage first**, using the saved-plan workflow from [stacks-and-state.md](stacks-and-state.md):

   ```bash
   cd tf/<layer>/stage
   tofu plan -out=plan
   tofu apply plan
   ```

4. Open the PR with the stage plan and apply output in the body. Confirm the plan contained nothing you did not intend; unrelated drift gets its own PR.
5. Get review, then merge.
6. Apply **prod** from `main` after the merge, with the same saved-plan workflow. Compare the prod plan to the stage plan: the resource-level shape should match, and only names, IDs, and counts should differ. If it does not match, stop — that mismatch means stage and prod have diverged and the divergence is the real bug.
7. If the prod apply fails or produces something unexpected, fix forward with a new PR through the same path. Do not revert `main` while prod is half-applied; state and code must be reconciled deliberately.

### `tf/infra/singletons/` is the exception

There is no staging equivalent. `gpo.ca`, the GitHub org, and the other global resources apply straight to live production.

- Open the PR with the **plan only**, and do not apply before merge.
- A human must read the plan and approve; an agent must not apply singletons on its own initiative. Confirm explicitly before running the apply.
- Keep singleton PRs as small as a change can be — one record, one repo, one ruleset.

### Bootstrap

`tf/bootstrap/` is run-once-per-environment and holds state buckets, KMS keys, and IAM. Same stage-first order, but assume every change is destructive until the plan proves otherwise, and get a human on the plan before applying either environment.

## Kubernetes (`kubernetes/`)

Same shape, different mechanics: ArgoCD applies on merge, so **merging is deploying**. See [kubernetes/README.md](../kubernetes/README.md) for the templating levels.

1. Change the shared source of truth, not the output: the chart version and values under `<workload>/stage/`, or the `templates/` for a `genk8s` workload. Never hand-edit a file under `rendered/`; regenerate it.
2. Re-render and commit the rendered manifests in the same PR (`mise <workload>:render`, `mise <workload>:genk8s`). The rendered diff is the review artifact — it is why we use the rendered manifests pattern, and a PR without it is unreviewable.
3. **Stage first, prod second, in two separate PRs.** Merge the stage PR, wait for ArgoCD to sync, verify the workload is healthy, and only then open the prod PR.
4. The prod PR should be the same change with prod values. Call out every difference between the two rendered diffs in the body; each one is either intentional or a bug.
5. Version bumps are pinned per environment on purpose. Bump stage, let it run, then bump prod to the version that has been running in stage.

## Docs

Docs describe what is true after the change, so they ship **with** it, in the same PR. A separate follow-up doc PR means `main` is wrong in the meantime.

- Behaviour changed → update the doc in the same PR. Adding a doc → add its row to the index table in `CLAUDE.md`.
- A decision with alternatives that were weighed and rejected goes in `DECISION_LOG.md`, newest at the top, with a link to the issue where it was discussed.
- Reference PRs and issues as full Markdown links, never a bare `#209`.

## Before opening any PR

- `pre-commit run --files <changed files>` (CI runs exactly this against the PR diff). In cloud agent sessions `terraform_validate` and `terraform_providers_lock` fail because `registry.opentofu.org` is unreachable — that is environmental, not your change. `terraform_fmt` must pass.
- No plaintext secrets. Anything sensitive goes through SOPS — see [secrets-and-sops.md](secrets-and-sops.md).
- Check for open PRs that touch the same files (`gh pr list` or the GitHub tools). If another open PR must land first, say so in the body with a link and do not merge out of order.
- Ready for review, not draft, unless the work is genuinely unfinished.

## PR body

Use `.github/pull_request_template.md`. The parts that matter most:

- **What and why**, in a sentence or two.
- **Applied**: which environment, plan summary, apply result. Say "not applied" if it was not, and say why.
- **Follow-ups**: prod apply pending, dependent PR, manual step required.

## Merging

- Squash merge. The PR title becomes the commit subject, so write it as one.
- Do not merge your own PR without a review unless it is a documented emergency; note the emergency in the body.
- Never merge with red CI. A failure that is genuinely environmental gets a comment saying which check and why before merge.
- After merge: apply prod (Terraform) or watch the ArgoCD sync (Kubernetes). The PR is not done at merge; it is done when prod is running it.
