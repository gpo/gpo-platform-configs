#!/bin/bash
# Lightweight check, not an install: the environment's Setup Script (see
# README.md) is expected to have already installed everything before the
# session starts, and re-running the full installer here on every session
# start just slows things down for no benefit once tools are present. This
# only checks versions and warns (to ~/.cloud-setup-errors.log) if
# something is missing or mismatched, so a broken Setup Script still
# surfaces instead of silently leaving tools unavailable.
set -uo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

cd "$CLAUDE_PROJECT_DIR" || exit 0

pin() {
  grep "^$1 = " .mise.toml | sed -E "s/.*= '([^']*)'/\1/"
}

warn() {
  local msg="gpo-platform-configs: $1 - run claude/cloud-environment-setup.sh (or .claude/setup-env.sh) to fix"
  echo "!! $msg"
  echo "$msg" >> ~/.cloud-setup-errors.log
}

check() {
  # check <tool-label> <version-check-command...> -- <expected-version>
  local label="$1" expected="${*: -1}"
  local cmd=("${@:2:$#-3}")
  if ! "${cmd[@]}" 2>/dev/null | grep -q "$expected"; then
    warn "$label missing or not at pinned version $expected"
  fi
}

check jq jq --version -- "$(pin jq)"
check gh command -v gh -- gh
check aws command -v aws -- aws
check pre-commit pre-commit --version -- "$(pin pre-commit)"
check helm helm version --short -- "v$(pin helm | sed 's/^v//')"
check tofu tofu --version -- "$(pin opentofu)"
check sops sops --version -- "$(pin sops)"
check argocd argocd version --client --short -- "$(pin argocd)"
check helmfile helmfile --version -- "$(pin helmfile)"
check yq yq --version -- "v$(pin yq | sed 's/^v//')"
