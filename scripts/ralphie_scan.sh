#!/usr/bin/env bash
set -euo pipefail

# Scan for ralphie.sh from the current directory.
# Exits 0 if found (prints paths), exits 1 if not found.

MAXDEPTH="${MAXDEPTH:-6}"

matches=$(find . -maxdepth "$MAXDEPTH" -name ralphie.sh -not -path '*/.git/*' -print || true)

if [[ -n "${matches}" ]]; then
  echo "Found ralphie.sh:" >&2
  echo "${matches}"
  exit 0
fi

echo "ralphie.sh not found (searched up to depth ${MAXDEPTH} from $(pwd))." >&2
exit 1
