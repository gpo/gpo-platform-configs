## What and why

<!-- One or two sentences. Link the issue if there is one. -->

## Applied

<!--
Terraform: paste the plan and the apply output for the environment THIS PR targets.
It is applied before this merges. Stage and prod are separate PRs — see docs/pull-requests.md.
Kubernetes: the rendered diff is the review; ArgoCD deploys on merge, so note the sync
status after it lands. Write "not applied" and why, if it was not.
-->

Environment: <!-- stage | prod | singletons | bootstrap -->

- [ ] Applied (Terraform) or rendered manifests committed (Kubernetes)
- [ ] Stage shipped and verified first, and the module is unchanged since (prod PRs only)
- [ ] Stage and prod share the same module or template; only variables differ
- [ ] Docs updated in this PR

## Follow-ups and dependencies

<!-- Pending prod apply, manual steps, or other PRs that must merge first (full links, not bare #numbers). -->
