#!/usr/bin/env bash
set -euo pipefail

# Check whether OpenClaw is configured to allow at least 2 concurrent agent runs
# (primary + one babysitter/liaison for Ralphie).
#
# Uses: openclaw config get agents.defaults.maxConcurrent

MIN_CONCURRENT_REQUIRED=2

if ! command -v openclaw >/dev/null 2>&1; then
  echo "openclaw CLI not found; cannot check concurrency." >&2
  exit 0
fi

val="$(openclaw config get agents.defaults.maxConcurrent --json 2>/dev/null || true)"
val="${val//$'\r'/}"

# val is JSON-ish; typically a number like: 10
if [[ ! "$val" =~ ^[0-9]+$ ]]; then
  echo "Could not parse agents.defaults.maxConcurrent from openclaw config (got: $val)" >&2
  exit 0
fi

if [ "$val" -lt "$MIN_CONCURRENT_REQUIRED" ]; then
  echo "OpenClaw maxConcurrent=$val, but Ralphie babysitting wants >= $MIN_CONCURRENT_REQUIRED (primary + liaison)." >&2
  echo "If you agree, bump it with:" >&2
  echo "  openclaw config set agents.defaults.maxConcurrent $MIN_CONCURRENT_REQUIRED --json" >&2
  exit 1
fi

echo "OK: OpenClaw maxConcurrent=$val (>= $MIN_CONCURRENT_REQUIRED)"
