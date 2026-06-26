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
python3 -c '
import sys, re
content = sys.stdin.read()
# Remove full spec.template.spec tree when initContainers: [] is its only child
content = re.sub(r"spec:\n  template:\n    spec:\n      initContainers: \[\]\n", "", content)
# Remove lone initContainers: [] (sibling of containers/volumes in a real pod spec)
content = re.sub(r"      initContainers: \[\]\n", "", content)
# Remove orphaned empty parent nodes left before a document separator
content = re.sub(r"    spec:\n(?=---)", "", content)
content = re.sub(r"  template:\n(?=---)", "", content)
sys.stdout.write(content)
'
