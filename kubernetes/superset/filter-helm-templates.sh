#!/usr/bin/env bash
set -euo pipefail

# these two secrets are managed by External Secrets - so remove them from the final render
yq ea '
  select(
    .kind != "Secret"
    or (
      .metadata.name != "superset-config"
      and .metadata.name != "superset-env"
    )
  )
' -
