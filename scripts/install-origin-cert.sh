#!/bin/bash
# Installs the gpo.ca Cloudflare Origin CA certificate on a droplet as forge,
# then reloads nginx. Safe to re-run: files are only replaced, and nginx only
# reloaded, when the content changes.
#
# Usage: scripts/install-origin-cert.sh forge@<host>

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 forge@<host>" >&2
  exit 64
fi
target=$1

repo_root=$(cd "$(dirname "$0")/.." && pwd)
stack="${repo_root}/tf/infra/singletons"
remote_dir=/home/forge/ssl/origin

cert=$(tofu -chdir="$stack" output -raw gpo_ca_origin_certificate_pem)
key=$(tofu -chdir="$stack" output -raw gpo_ca_origin_private_key_pem)

if [[ $cert != *"BEGIN CERTIFICATE"* || $key != *"PRIVATE KEY"* ]]; then
  echo "tofu outputs are missing or malformed; apply tf/infra/singletons first." >&2
  exit 1
fi

local_sums=$(printf '%s\n' "$cert" | shasum -a 256 | cut -d' ' -f1; printf '%s\n' "$key" | shasum -a 256 | cut -d' ' -f1)
remote_sums=$(ssh "$target" "cat ${remote_dir}/cert.pem 2>/dev/null | sha256sum | cut -d' ' -f1; cat ${remote_dir}/key.pem 2>/dev/null | sha256sum | cut -d' ' -f1")

if [[ $local_sums == "$remote_sums" ]]; then
  echo "${target}: origin certificate already current."
  exit 0
fi

ssh "$target" "umask 077 && mkdir -p ${remote_dir} && cat > ${remote_dir}/key.pem.new && mv ${remote_dir}/key.pem.new ${remote_dir}/key.pem" <<<"$key"
ssh "$target" "umask 022 && cat > ${remote_dir}/cert.pem.new && mv ${remote_dir}/cert.pem.new ${remote_dir}/cert.pem" <<<"$cert"
echo "${target}: wrote ${remote_dir}/cert.pem and key.pem."

# nginx validates the config on reload and keeps the running config if it is
# invalid, so a bad file cannot take the site down. forge cannot run nginx -t.
ssh "$target" "sudo -n service nginx reload && sudo -n service nginx status | grep --quiet 'Active: active'"
echo "${target}: nginx reloaded and active."

