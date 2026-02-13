#!/usr/bin/env bash
set -euo pipefail

# Copy Ralphie into a target project directory.
#
# Usage:
#   bash scripts/ralphie_copy.sh --to /path/to/project [--force]
#
# Behavior:
# - Copies the vendored upstream `scripts/ralphie.sh` into <project>/ralphie.sh
# - Marks it executable
# - Records an audit line in ~/.openclaw/skills/ralphie-skill/runs.jsonl when possible

TO=""
FORCE=false

usage() {
  cat <<'USAGE'
Usage: bash scripts/ralphie_copy.sh --to <project-dir> [--force]

Options:
  --to <dir>   Target project directory
  --force      Overwrite existing <project>/ralphie.sh
  -h, --help   Show help
USAGE
}

while [ $# -gt 0 ]; do
  case "$1" in
    --to) TO="$2"; shift 2;;
    --force) FORCE=true; shift;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown arg: $1" >&2; exit 2;;
  esac
done

if [ -z "$TO" ]; then
  echo "Missing --to <project-dir>" >&2
  exit 2
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$REPO_ROOT/scripts/ralphie.sh"
DST="$TO/ralphie.sh"

if [ ! -f "$SRC" ]; then
  echo "Vendored ralphie.sh not found at: $SRC" >&2
  exit 1
fi

if [ ! -d "$TO" ]; then
  echo "Target directory does not exist: $TO" >&2
  exit 1
fi

if [ -e "$DST" ] && [ "$FORCE" != true ]; then
  echo "Refusing to overwrite existing: $DST (use --force)" >&2
  exit 1
fi

cp "$SRC" "$DST"
chmod +x "$DST" || true

echo "Copied: $SRC -> $DST"

# Best-effort run tracking (local only).
STATE_DIR="$HOME/.openclaw/skills/ralphie-skill"
STATE_FILE="$STATE_DIR/runs.jsonl"
mkdir -p "$STATE_DIR" 2>/dev/null || true

python3 - <<'PY' "$STATE_FILE" "$TO" "$DST" 2>/dev/null || true
import json, os, sys, time
out = sys.argv[1]
project_dir = sys.argv[2]
ralphie_path = sys.argv[3]
rec = {
  "ts": int(time.time()),
  "action": "copy",
  "projectDir": os.path.abspath(project_dir),
  "ralphiePath": os.path.abspath(ralphie_path),
}
with open(out, "a", encoding="utf-8") as f:
  f.write(json.dumps(rec, ensure_ascii=False) + "\n")
PY
