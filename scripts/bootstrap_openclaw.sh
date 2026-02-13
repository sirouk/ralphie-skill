#!/usr/bin/env bash
set -euo pipefail

# Ralphie Skill bootstrap: install this repo as an OpenClaw skill (symlink or copy).
# Usage:
#   bash scripts/bootstrap_openclaw.sh [--copy|--symlink] [--dir <skills-parent>] [--no-color]
#
# Installs into ONE of:
#   - <openclaw-workspace>/skills/
#   - ~/.openclaw/workspace/skills/
#   - ~/.openclaw/skills/
#
# Notes:
# - This repo *is* the skill directory (root contains SKILL.md).
# - Default is symlink so updating this repo updates the installed skill.

USE_COLOR=true
for arg in "$@"; do
  if [ "$arg" = "--no-color" ]; then
    USE_COLOR=false
    break
  fi
done

if [ "$USE_COLOR" = true ]; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  BLUE='\033[0;34m'
  NC='\033[0m'
else
  RED=''
  GREEN=''
  YELLOW=''
  BLUE=''
  NC=''
fi

log_info() { echo -e "${BLUE}info:${NC} $1"; }
log_ok() { echo -e "${GREEN}ok:${NC} $1"; }
log_warn() { echo -e "${YELLOW}warn:${NC} $1"; }
log_err() { echo -e "${RED}error:${NC} $1" >&2; exit 1; }

SKILL_NAME="ralphie-skill"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [ ! -f "$REPO_ROOT/SKILL.md" ]; then
  log_err "Expected SKILL.md at repo root: $REPO_ROOT"
fi

INSTALL_MODE="symlink"  # symlink|copy
TARGET_PARENT=""        # directory that will contain <skill-name>/

usage() {
  cat <<USAGE
Usage: bash scripts/bootstrap_openclaw.sh [options]

Options:
  --symlink            Install via symlink (default)
  --copy               Install via copy
  --dir <skills-parent>  Install into this directory (it will contain ralphie-skill/)
  --no-color           Disable ANSI colors
  -h, --help           Show help

Environment overrides:
  OPENCLAW_SKILLS_PARENT=<dir>  Same as --dir
  OPENCLAW_WORKSPACE_DIR=<dir>  Preferred workspace root (used for auto-detect)
USAGE
}

while [ $# -gt 0 ]; do
  case "$1" in
    --symlink) INSTALL_MODE="symlink"; shift ;;
    --copy) INSTALL_MODE="copy"; shift ;;
    --dir) TARGET_PARENT="$2"; shift 2 ;;
    --no-color) shift ;;
    -h|--help) usage; exit 0 ;;
    *) log_err "Unknown arg: $1" ;;
  esac
done

if [ -z "$TARGET_PARENT" ] && [ -n "${OPENCLAW_SKILLS_PARENT:-}" ]; then
  TARGET_PARENT="$OPENCLAW_SKILLS_PARENT"
fi

# Detect OpenClaw workspace root from env or ~/.openclaw/openclaw.json.
detect_openclaw_workspace_root() {
  if [ -n "${OPENCLAW_WORKSPACE_DIR:-}" ]; then
    printf "%s" "$OPENCLAW_WORKSPACE_DIR"
    return 0
  fi

  local cfg="$HOME/.openclaw/openclaw.json"
  if [ -f "$cfg" ] && command -v python3 >/dev/null 2>&1; then
    python3 - "$cfg" <<'PY' 2>/dev/null || true
import json, sys
path = sys.argv[1]
try:
  with open(path, 'r', encoding='utf-8') as f:
    data = json.load(f)
except Exception:
  sys.exit(0)

ws = (((data.get('agents') or {}).get('defaults') or {}).get('workspace'))
if isinstance(ws, str) and ws.strip():
  print(ws.strip(), end='')
  sys.exit(0)

ws = data.get('workspace')
if isinstance(ws, str) and ws.strip():
  print(ws.strip(), end='')
PY
  fi
}

if [ -z "$TARGET_PARENT" ]; then
  ws="$(detect_openclaw_workspace_root || true)"
  ws="${ws//$'\r'/}"

  if [ -n "$ws" ] && [ -d "$ws" ]; then
    if [ -d "$ws/skills" ]; then
      TARGET_PARENT="$ws/skills"
    else
      # Common convention if the workspace root exists but skills/ doesn't yet.
      TARGET_PARENT="$ws/skills"
    fi
  elif [ -d "$HOME/.openclaw/workspace" ]; then
    TARGET_PARENT="$HOME/.openclaw/workspace/skills"
  else
    TARGET_PARENT="$HOME/.openclaw/skills"
  fi
fi

TARGET_PARENT="${TARGET_PARENT%/}"
TARGET_DIR="$TARGET_PARENT/$SKILL_NAME"

log_info "Repo root:      $REPO_ROOT"
log_info "Install mode:   $INSTALL_MODE"
log_info "Target parent:  $TARGET_PARENT"
log_info "Target dir:     $TARGET_DIR"

mkdir -p "$TARGET_PARENT"

if [ "$INSTALL_MODE" = "symlink" ]; then
  # Replace existing link/dir.
  if [ -L "$TARGET_DIR" ] || [ -e "$TARGET_DIR" ]; then
    rm -rf "$TARGET_DIR"
  fi
  ln -s "$REPO_ROOT" "$TARGET_DIR"
  log_ok "Installed via symlink: $TARGET_DIR -> $REPO_ROOT"
elif [ "$INSTALL_MODE" = "copy" ]; then
  rm -rf "$TARGET_DIR"
  mkdir -p "$TARGET_DIR"
  rsync -a --delete \
    --exclude '.git' \
    --exclude 'node_modules' \
    "$REPO_ROOT/" "$TARGET_DIR/"
  log_ok "Installed via copy: $TARGET_DIR"
else
  log_err "Unknown INSTALL_MODE: $INSTALL_MODE"
fi

verify_openclaw_sees_skill() {
  if ! command -v openclaw >/dev/null 2>&1; then
    log_warn "openclaw CLI not found; skipping verification step."
    return 0
  fi

  # Best-effort: ensure the skill shows up in OpenClaw's indexed skills.
  # This does NOT guarantee it will trigger on a given prompt, but it confirms discovery.
  if openclaw skills list 2>/dev/null | rg -q "^${SKILL_NAME}\b"; then
    log_ok "Verified: openclaw skills list contains ${SKILL_NAME}"
    return 0
  fi

  log_warn "Could not confirm ${SKILL_NAME} via: openclaw skills list"
  log_warn "Next steps: restart the gateway or refresh skills, then re-run: openclaw skills list"
  return 0
}

verify_openclaw_sees_skill

log_ok "Done. Restart/refresh OpenClaw skills if needed."
log_info "Tip: you can run: openclaw skills list | rg '^ralphie-skill\\b'"
