#!/usr/bin/env bash
set -euo pipefail

# Run a local ralphie.sh in the background and write logs + pid.
# Usage:
#   ./scripts/ralphie_run_bg.sh [path_to_ralphie_sh]
#
# Outputs:
#   ./.ralphie/ralphie.log
#   ./.ralphie/ralphie.pid

RALPHIE_SH="${1:-./ralphie.sh}"
LOG_DIR="${RALPHIE_LOG_DIR:-.ralphie}"
LOG_FILE="${RALPHIE_LOG_FILE:-${LOG_DIR}/ralphie.log}"
PID_FILE="${RALPHIE_PID_FILE:-${LOG_DIR}/ralphie.pid}"

if [[ ! -x "$RALPHIE_SH" ]]; then
  echo "Not executable or not found: $RALPHIE_SH" >&2
  echo "If you just installed it, run: chmod +x '$RALPHIE_SH'" >&2
  exit 2
fi

mkdir -p "$LOG_DIR"

# If already running, bail.
if [[ -f "$PID_FILE" ]]; then
  oldpid=$(cat "$PID_FILE" || true)
  if [[ -n "${oldpid}" ]] && kill -0 "${oldpid}" 2>/dev/null; then
    echo "Ralphie appears to already be running (pid ${oldpid})." >&2
    echo "Log: ${LOG_FILE}" >&2
    exit 0
  fi
fi

echo "Starting Ralphie in background…" >&2
# shellcheck disable=SC2091
( "$RALPHIE_SH" ) >>"$LOG_FILE" 2>&1 &
newpid=$!

echo "$newpid" > "$PID_FILE"

echo "Ralphie pid: ${newpid}" >&2
echo "Log: ${LOG_FILE}" >&2
