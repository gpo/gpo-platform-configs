#!/bin/bash
# Installs the CLI tools pinned in .mise.toml (plus gh/aws from the README)
# so tofu/pre-commit/sops/etc. are ready to use in a Claude Code on the web session.
set -uo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

log() { echo "[session-start] $*"; }

has_version() {
  # has_version <check-command...> -- <needle>
  local out
  out="$("$@" 2>&1)" || true
  printf '%s' "$out"
}

BIN=/usr/local/bin

# --- jq (pinned 1.8.1; apt currently tops out at 1.7.x, close enough) ---
if ! command -v jq >/dev/null 2>&1; then
  log "installing jq via apt"
  apt-get update -qq && apt-get install -y -qq jq
else
  log "jq already present: $(jq --version)"
fi

# --- gh CLI (README prerequisite, not version-pinned) ---
if ! command -v gh >/dev/null 2>&1; then
  log "installing gh via apt"
  apt-get update -qq && apt-get install -y -qq gh
else
  log "gh already present: $(gh --version | head -1)"
fi

# --- pre-commit (pinned 4.5.0) ---
if ! has_version pre-commit --version | grep -q '4\.5\.0'; then
  log "installing pre-commit 4.5.0 via pip"
  pip3 install --break-system-packages -q 'pre-commit==4.5.0' || log "WARN: pre-commit install failed"
else
  log "pre-commit already at 4.5.0"
fi

# --- helm (pinned v4.1.4) ---
if ! has_version helm version --short | grep -q 'v4\.1\.4'; then
  log "installing helm v4.1.4"
  tmp=$(mktemp -d)
  if curl -fsSL -o "$tmp/helm.tar.gz" "https://get.helm.sh/helm-v4.1.4-linux-amd64.tar.gz"; then
    tar -xzf "$tmp/helm.tar.gz" -C "$tmp"
    install -m 0755 "$tmp/linux-amd64/helm" "$BIN/helm"
  else
    log "WARN: helm download failed (check get.helm.sh reachability)"
  fi
  rm -rf "$tmp"
else
  log "helm already at v4.1.4"
fi

# --- aws cli (README prerequisite, not version-pinned) ---
if ! command -v aws >/dev/null 2>&1; then
  log "installing aws cli"
  tmp=$(mktemp -d)
  if curl -fsSL -o "$tmp/awscliv2.zip" "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"; then
    unzip -q "$tmp/awscliv2.zip" -d "$tmp"
    "$tmp/aws/install" --update
  else
    log "WARN: aws cli download failed (check awscli.amazonaws.com reachability)"
  fi
  rm -rf "$tmp"
else
  log "aws cli already present: $(aws --version)"
fi

# --- go-installable tools: sops, yq, helmfile (pinned versions) ---
if command -v go >/dev/null 2>&1; then
  if ! has_version sops --version | grep -q '3\.11\.0'; then
    log "installing sops 3.11.0 via go install"
    GOBIN="$BIN" go install github.com/getsops/sops/v3/cmd/sops@v3.11.0 || log "WARN: sops install failed"
  else
    log "sops already at 3.11.0"
  fi

  if ! has_version yq --version | grep -q 'v4\.50\.1'; then
    log "installing yq v4.50.1 via go install"
    GOBIN="$BIN" go install github.com/mikefarah/yq/v4@v4.50.1 || log "WARN: yq install failed"
  else
    log "yq already at v4.50.1"
  fi

  if ! has_version helmfile --version | grep -q 'v1\.2\.2'; then
    log "installing helmfile v1.2.2 via go install"
    GOBIN="$BIN" go install github.com/helmfile/helmfile@v1.2.2 || log "WARN: helmfile install failed"
  else
    log "helmfile already at v1.2.2"
  fi
else
  log "WARN: go not found, skipping sops/yq/helmfile (install Go or fetch these another way)"
fi

# --- OpenTofu (pinned 1.9.1) ---
# go.mod has replace directives, so `go install` doesn't work here; use the
# official installer, which needs get.opentofu.org reachable.
if ! has_version tofu --version | grep -q '1\.9\.1'; then
  log "installing OpenTofu 1.9.1 via official installer"
  tmp=$(mktemp -d)
  if curl -fsSL -o "$tmp/install-opentofu.sh" "https://get.opentofu.org/install-opentofu.sh"; then
    chmod +x "$tmp/install-opentofu.sh"
    "$tmp/install-opentofu.sh" --install-method standalone --opentofu-version 1.9.1 --install-path "$BIN" \
      || log "WARN: OpenTofu install failed"
  else
    log "WARN: could not reach get.opentofu.org — add it to the network allowlist to install OpenTofu"
  fi
  rm -rf "$tmp"
else
  log "OpenTofu already at 1.9.1"
fi

# --- Argo CD CLI (pinned 3.2.1) ---
# Same go.mod replace-directive issue as OpenTofu; fetch the prebuilt binary
# from GitHub releases instead (needs github.com release-asset access).
if ! has_version argocd version --client --short | grep -q '3\.2\.1'; then
  log "installing argocd 3.2.1 from GitHub release binary"
  if curl -fsSL -o "$BIN/argocd" "https://github.com/argoproj/argo-cd/releases/download/v3.2.1/argocd-linux-amd64"; then
    chmod 0755 "$BIN/argocd"
  else
    log "WARN: could not download argocd release binary — needs github.com release access (or quay.io for the container image)"
    rm -f "$BIN/argocd"
  fi
else
  log "argocd already at 3.2.1"
fi

log "done"
