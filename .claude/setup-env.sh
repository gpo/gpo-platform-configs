#!/bin/bash
# Thin delegate to the canonical setup script - nothing to keep in sync.
exec bash "$(dirname "$0")/../claude/cloud-environment-setup.sh"
