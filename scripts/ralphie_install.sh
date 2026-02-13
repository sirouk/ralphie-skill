#!/usr/bin/env bash
set -euo pipefail

# Download ralphie.sh into the current directory (default: ./ralphie.sh).
# Usage:
#   ./scripts/ralphie_install.sh [output_path]

URL="${RALPHIE_URL:-https://raw.githubusercontent.com/sirouk/ralphie/refs/heads/master/ralphie.sh}"
OUT="${1:-./ralphie.sh}"

if [[ -e "$OUT" ]]; then
  echo "Refusing to overwrite existing file: $OUT" >&2
  exit 2
fi

mkdir -p "$(dirname "$OUT")"

echo "Downloading Ralphie from: $URL" >&2
curl -fsSL "$URL" -o "$OUT"
chmod +x "$OUT"

echo "Installed: $OUT" >&2

echo "Tip: skim it first: sed -n '1,120p' '$OUT'" >&2
