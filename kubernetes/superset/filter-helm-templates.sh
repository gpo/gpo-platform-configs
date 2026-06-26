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
' - | \
yq ea '(.spec.template.spec.initContainers[]?.resources) |= del(.requests)' - | \
yq ea 'del(.spec.template.spec.initContainers | select(tag == "!!seq" and length == 0))' - | \
yq ea 'del(.spec.template.spec | select(tag == "!!map" and length == 0))' - | \
yq ea 'del(.spec.template | select(tag == "!!map" and length == 0))' - | \
yq ea 'del(.spec | select(tag == "!!map" and length == 0))' -
