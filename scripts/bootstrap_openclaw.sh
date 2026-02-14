#!/usr/bin/env bash
set -euo pipefail

# Backward-compatible wrapper. The canonical installer is:
#   scripts/bootstrap_ralphie.sh

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec bash "$HERE/bootstrap_ralphie.sh" "$@"

