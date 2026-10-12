# Tax Receipts

The Tax Receipts & Contributions tool from `gpo/gpo-monolith` (`apps/tax-receipts/`). One StatefulSet pod runs the `api` and `web` containers; PostgreSQL is a CNPG cluster; receipt PDFs live on the pod's PVC. Images are built by hand from the monolith and pushed with the `staging` tag. The app's own deploy notes are `apps/tax-receipts/DEPLOY.md` in the monolith.

Every command below targets stage. Set up access once:

```sh
gcloud container clusters get-credentials gpo-stage --zone=northamerica-northeast2-a --project=gpo-eng-stage
gcloud auth configure-docker northamerica-northeast2-docker.pkg.dev
```

## Ship a new version

From the root of a `gpo/gpo-monolith` checkout at the commit to ship. `--platform=linux/amd64` matters on Apple Silicon: an arm64 image fails on the GKE nodes.

```sh
REGISTRY=northamerica-northeast2-docker.pkg.dev/gpo-eng-stage/gpo
SHA=$(git rev-parse --short HEAD)
for target in api api-tools web; do
  docker buildx build --platform=linux/amd64 --file=apps/tax-receipts/Dockerfile --target="$target" \
    --tag="$REGISTRY/tax-receipts-$target:staging" --tag="$REGISTRY/tax-receipts-$target:$SHA" --push .
done
```

Migrate, then restart the app so both containers pull the new `staging` images. Jobs are immutable, so the migration Job is deleted and re-created:

```sh
kubectl --namespace=tax-receipts delete job tax-receipts-migration --ignore-not-found
kubectl --namespace=tax-receipts apply --filename=kubernetes/tax-receipts/stage/job.yaml
kubectl --namespace=tax-receipts wait --for=condition=complete job/tax-receipts-migration --timeout=5m
kubectl --namespace=tax-receipts apply --filename=kubernetes/tax-receipts/stage/statefulset.yaml
kubectl --namespace=tax-receipts rollout restart statefulset/tax-receipts-app
kubectl --namespace=tax-receipts rollout status statefulset/tax-receipts-app
```

## Load the mock data

`oneoff/seed-fixtures-job.yaml` runs `prisma/seed.ts` (ridings, periods, limits, the `@gpo.test` users) and `prisma/seed-fixtures.ts` (mock contributors, contributions, and issued receipts). Both are idempotent, and `seed.ts` leaves existing users' passwords alone. Stage only: never apply it to prod.

The fixtures write receipt PDFs to the app's ReadWriteOnce PVC, so the app is scaled down while the Job runs:

```sh
kubectl --namespace=tax-receipts scale statefulset/tax-receipts-app --replicas=0
kubectl --namespace=tax-receipts delete job tax-receipts-seed-fixtures --ignore-not-found
kubectl --namespace=tax-receipts apply --filename=kubernetes/tax-receipts/oneoff/seed-fixtures-job.yaml
kubectl --namespace=tax-receipts wait --for=condition=complete job/tax-receipts-seed-fixtures --timeout=10m
kubectl --namespace=tax-receipts logs job/tax-receipts-seed-fixtures
kubectl --namespace=tax-receipts scale statefulset/tax-receipts-app --replicas=1
```

If the Job fails, read its logs before re-running; the app stays down until the last command runs.
