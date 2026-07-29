#!/bin/bash
# Fallback for environments without the Setup Script block in README.md:
# runs the same canonical install script directly in-session. Unlike
# canopy/gpo-ca, this is expected to actually succeed here too - the tools
# this repo needs come from public GitHub Release binaries and apt/pip,
# none of which are subject to the git/API scoping that blocks a live
# session from installing canopy's composer dependencies.
set -uo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

exec bash "$CLAUDE_PROJECT_DIR/claude/cloud-environment-setup.sh"
