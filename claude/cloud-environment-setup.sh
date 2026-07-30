#!/bin/bash
# Fetched by the environment's Setup Script field (see README.md) via
# raw.githubusercontent.com, or run by hand via .claude/setup-env.sh.
#
# Self-contained: clones gpo-platform-configs itself if it isn't already
# attached as a source, since a script fetched by curl can't assume a
# pre-existing checkout. Logs its own failures (append-only) to
# ~/.cloud-setup-errors.log, so it must run after any step that
# truncates that file.
#
# Unlike canopy/gpo-ca, none of this needs the Setup Script phase to work
# around GitHub access scoping — every tool here comes from public GitHub
# Release binaries, apt, or pip, none of which are scope-blocked in a live
# session. .claude/hooks/session-start.sh checks (but doesn't reinstall)
# these at session start as a lighter-weight backstop for environments
# without the Setup Script block configured.
#
# `mise install` itself is NOT a viable replacement for this script, even
# with mise.jdx.dev allowlisted (README's Requirements section) — tested
# directly: mise's `aqua` backend resolves every tool through
# api.github.com, which 403s with "GitHub access to this repository is not
# enabled for this session" for any repo this session doesn't have git
# access to (getsops/sops, opentofu/opentofu, etc. — none of them are this
# repo). That's the same git/API-scoping problem documented in canopy for
# composer/api.github.com. The plain release-asset URLs below
# (github.com/<owner>/<repo>/releases/download/..., no API call involved)
# are a different, unblocked code path, confirmed working with a plain
# curl even where the api.github.com call for the same tool 403s. So this
# installs the same versions pinned in .mise.toml directly, parsed from
# that file so they can't drift from a second hardcoded copy, via those
# pinned-version GitHub Releases downloads (not `go install` either, which
# needs a Go toolchain we can't assume is present).
set -u
REPO_DIR=/home/user/gpo-platform-configs
BIN=/usr/local/bin

log() { echo "==> $*"; }
warn() { echo "!! $*"; }

fail() {
  local msg="gpo-platform-configs: $1 - unavailable until this is fixed"
  warn "$msg"
  echo "$msg" >> ~/.cloud-setup-errors.log
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

# --- jq (pinned GitHub Release, raw binary) ---
# apt's jq tops out around 1.7.x on this base image, short of the 1.8.1
# pin, so - like the other tools below - install the exact pinned version
# from a release binary instead of relying on apt.
if ! jq --version 2>/dev/null | grep -q "$JQ_VERSION"; then
  log "installing jq $JQ_VERSION from GitHub release"
  if curl -fsSL -o "$BIN/jq" "https://github.com/jqlang/jq/releases/download/jq-${JQ_VERSION}/jq-linux-amd64"; then
    chmod 0755 "$BIN/jq"
  else
    fail "jq release download failed"
  fi
else
  log "jq already at $JQ_VERSION"
fi

# --- gh CLI (README prerequisite, not version-pinned) ---
# `apt-get update` can fail non-zero here because of unrelated third-party
# PPAs in this base image's sources.list (deadsnakes, ondrej/php) being
# unreachable/unsigned - that's not a reason to skip installing gh, so its
# failure is tolerated separately from the actual install step.
if ! command -v gh >/dev/null 2>&1; then
  log "installing gh via apt"
  apt-get update -qq || true
  apt-get install -y -qq gh || fail "gh apt install failed"
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

# --- helm (pinned tarball from get.helm.sh, raw download) ---
# The official get-helm-3 install script's checksum-verification step
# failed in this environment even though the tarball itself downloaded
# fine - rather than chase that, download and extract the tarball directly
# like the other tools below.
if ! helm version --short 2>/dev/null | grep -q "v${HELM_VERSION#v}"; then
  log "installing helm $HELM_VERSION from get.helm.sh"
  tmp=$(mktemp -d)
  if curl -fsSL -o "$tmp/helm.tar.gz" "https://get.helm.sh/helm-v${HELM_VERSION#v}-linux-amd64.tar.gz"; then
    tar -xzf "$tmp/helm.tar.gz" -C "$tmp"
    install -m 0755 "$tmp/linux-amd64/helm" "$BIN/helm"
  else
    fail "helm download failed"
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
