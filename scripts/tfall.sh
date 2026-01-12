#!/bin/bash

# Usage: ./tofu-all <command> [args...]
# Example: ./tofu-all init
#          ./tofu-all plan

set -e

if [ $# -lt 1 ]; then
  echo "Usage: $0 <command> [args...]"
  exit 1
fi

find . -name tofu.tf -not -path "./tf/modules/*" -execdir bash -c 'echo "Running: tofu $* in $(pwd)"; tofu "$@"' _ "$@" \;
