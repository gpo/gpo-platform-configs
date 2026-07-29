#!/bin/bash
# Fetched by the environment's Setup Script field (see README.md) via
# raw.githubusercontent.com, or run by hand via .claude/setup-env.sh.
#
# Self-contained: clones gpo-platform-configs itself if it isn't already
# attached as a source, since a script fetched by curl can't assume a
# pre-existing checkout. Logs its own failures (append-only) to
# ~/.claude/cloud-setup-errors.log, so it must run after any step that
# truncates that file.
#
# Unlike canopy/gpo-ca, none of this needs the Setup Script phase to work
# around GitHub access scoping — every tool here comes from public GitHub
# Release binaries, apt, or pip, none of which are scope-blocked in a live
# session. .claude/hooks/session-start.sh checks (but doesn't reinstall)
# these at session start as a lighter-weight backstop for environments
# without the Setup Script block configured.
#
# We'd rather just run `mise install`, and this script may become that one
# day, but it can't right now: mise.jdx.dev is unreachable from this
# environment (confirmed by direct curl - connection refused), and mise's
# own installer script fails for the same reason, even though the plain
# GitHub Release downloads it would eventually fetch on our behalf do not.
# So this installs the same versions pinned in .mise.toml directly, parsed
# from that file so they can't drift from a second hardcoded copy, via
# pinned-version GitHub Releases downloads (not `go install`, which needs a
# Go toolchain we can't assume is present) — a different, unblocked network
# path from scoped git/API access.
set -u
REPO_DIR=/home/user/gpo-platform-configs
BIN=/usr/local/bin

log() { echo "==> $*"; }
warn() { echo "!! $*"; }

fail() {
  local msg="gpo-platform-configs: $1 - unavailable until this is fixed"
  warn "$msg"
  mkdir -p ~/.claude
  echo "$msg" >> ~/.claude/cloud-setup-errors.log
}

if [ ! -d "$REPO_DIR/.git" ]; then
  log "cloning gpo/gpo-platform-configs"
  if ! git clone --depth 1 https://github.com/gpo/gpo-platform-configs.git "$REPO_DIR"; then
    fail "git clone failed"
    exit 0
  fi
fi
cd "$REPO_DIR"

pin() {
  # pin <tool-name-in-.mise.toml>
  grep "^$1 = " .mise.toml | sed -E "s/.*= '([^']*)'/\1/"
}

OPENTOFU_VERSION="$(pin opentofu)"
PRECOMMIT_VERSION="$(pin pre-commit)"
SOPS_VERSION="$(pin sops)"
JQ_VERSION="$(pin jq)"
ARGOCD_VERSION="$(pin argocd)"
HELMFILE_VERSION="$(pin helmfile)"
YQ_VERSION="$(pin yq)"
HELM_VERSION="$(pin helm)"

# --- jq ---
if ! command -v jq >/dev/null 2>&1; then
  log "installing jq via apt"
  apt-get update -qq && apt-get install -y -qq jq || fail "jq apt install failed"
else
  log "jq already present: $(jq --version)"
fi

# --- gh CLI (README prerequisite, not version-pinned) ---
if ! command -v gh >/dev/null 2>&1; then
  log "installing gh via apt"
  apt-get update -qq && apt-get install -y -qq gh || fail "gh apt install failed"
else
  log "gh already present: $(gh --version | head -1)"
fi

# --- aws cli (README prerequisite, not version-pinned) ---
if ! command -v aws >/dev/null 2>&1; then
  log "installing aws cli"
  tmp=$(mktemp -d)
  if curl -fsSL -o "$tmp/awscliv2.zip" "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"; then
    unzip -q "$tmp/awscliv2.zip" -d "$tmp"
    "$tmp/aws/install" --update || fail "aws cli install failed"
  else
    fail "aws cli download failed"
  fi
  rm -rf "$tmp"
else
  log "aws cli already present: $(aws --version)"
fi

# --- pre-commit ---
if ! pre-commit --version 2>/dev/null | grep -q "$PRECOMMIT_VERSION"; then
  log "installing pre-commit $PRECOMMIT_VERSION via pip"
  pip3 install --break-system-packages -q "pre-commit==$PRECOMMIT_VERSION" || fail "pre-commit install failed"
else
  log "pre-commit already at $PRECOMMIT_VERSION"
fi

# --- helm (official install script) ---
if ! helm version --short 2>/dev/null | grep -q "v${HELM_VERSION#v}"; then
  log "installing helm $HELM_VERSION via official install script"
  tmp=$(mktemp -d)
  if curl -fsSL -o "$tmp/get-helm.sh" "https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3"; then
    chmod +x "$tmp/get-helm.sh"
    "$tmp/get-helm.sh" --version "v${HELM_VERSION#v}" --no-sudo || fail "helm install failed"
  else
    fail "could not fetch helm install script"
  fi
  rm -rf "$tmp"
else
  log "helm already at $HELM_VERSION"
fi

# --- OpenTofu (pinned GitHub Release, zip) ---
if ! tofu --version 2>/dev/null | grep -q "$OPENTOFU_VERSION"; then
  log "installing OpenTofu $OPENTOFU_VERSION from GitHub release"
  tmp=$(mktemp -d)
  if curl -fsSL -o "$tmp/tofu.zip" "https://github.com/opentofu/opentofu/releases/download/v${OPENTOFU_VERSION}/tofu_${OPENTOFU_VERSION}_linux_amd64.zip"; then
    unzip -q "$tmp/tofu.zip" -d "$tmp"
    install -m 0755 "$tmp/tofu" "$BIN/tofu"
  else
    fail "OpenTofu release download failed"
  fi
  rm -rf "$tmp"
else
  log "OpenTofu already at $OPENTOFU_VERSION"
fi

# --- sops (pinned GitHub Release, raw binary) ---
if ! sops --version 2>/dev/null | grep -q "$SOPS_VERSION"; then
  log "installing sops $SOPS_VERSION from GitHub release"
  if curl -fsSL -o "$BIN/sops" "https://github.com/getsops/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux.amd64"; then
    chmod 0755 "$BIN/sops"
  else
    fail "sops release download failed"
  fi
else
  log "sops already at $SOPS_VERSION"
fi

# --- argocd (pinned GitHub Release, raw binary) ---
if ! argocd version --client --short 2>/dev/null | grep -q "$ARGOCD_VERSION"; then
  log "installing argocd $ARGOCD_VERSION from GitHub release"
  if curl -fsSL -o "$BIN/argocd" "https://github.com/argoproj/argo-cd/releases/download/v${ARGOCD_VERSION}/argocd-linux-amd64"; then
    chmod 0755 "$BIN/argocd"
  else
    fail "argocd release download failed"
  fi
else
  log "argocd already at $ARGOCD_VERSION"
fi

# --- helmfile (pinned GitHub Release, tar.gz) ---
if ! helmfile --version 2>/dev/null | grep -q "$HELMFILE_VERSION"; then
  log "installing helmfile $HELMFILE_VERSION from GitHub release"
  tmp=$(mktemp -d)
  if curl -fsSL -o "$tmp/helmfile.tar.gz" "https://github.com/helmfile/helmfile/releases/download/v${HELMFILE_VERSION}/helmfile_${HELMFILE_VERSION}_linux_amd64.tar.gz"; then
    tar -xzf "$tmp/helmfile.tar.gz" -C "$tmp"
    install -m 0755 "$tmp/helmfile" "$BIN/helmfile"
  else
    fail "helmfile release download failed"
  fi
  rm -rf "$tmp"
else
  log "helmfile already at $HELMFILE_VERSION"
fi

# --- yq (pinned GitHub Release, raw binary) ---
YQ_TAG="$YQ_VERSION"
[[ "$YQ_TAG" == v* ]] || YQ_TAG="v$YQ_TAG"
if ! yq --version 2>/dev/null | grep -q "$YQ_TAG"; then
  log "installing yq $YQ_TAG from GitHub release"
  if curl -fsSL -o "$BIN/yq" "https://github.com/mikefarah/yq/releases/download/${YQ_TAG}/yq_linux_amd64"; then
    chmod 0755 "$BIN/yq"
  else
    fail "yq release download failed"
  fi
else
  log "yq already at $YQ_TAG"
fi

log "done"
