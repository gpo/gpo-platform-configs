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
yq ea '
  if .spec.template.spec.initContainers == [] then del(.spec.template.spec.initContainers) else . end |
  if .spec.template.spec == {} then del(.spec.template.spec) else . end |
  if .spec.template == {} then del(.spec.template) else . end |
  if .spec == {} then del(.spec) else . end
' -
