#!/usr/bin/env bash
# SAEED autonomous improvement runner.
# Repeatedly invokes the team on a target repo until the improvement lead
# declares CONVERGED, the user drops a STOP file, or MAX_CYCLES is reached.
#
# Usage:  scripts/saeed-loop.sh /path/to/target-repo [max_cycles] [sleep_seconds]
# Requires the Claude Code CLI (`claude`) on PATH and the SAEED plugin installed.
set -euo pipefail

REPO="${1:-$(pwd)}"
MAX_CYCLES="${2:-50}"
SLEEP_SECONDS="${3:-0}"

cd "$REPO"
mkdir -p .saeed

echo "SAEED loop starting in: $REPO (max $MAX_CYCLES cycles)"

for ((i=1; i<=MAX_CYCLES; i++)); do
  if [[ -f .saeed/STOP ]]; then
    echo "SAEED: STOP file present. Halting at cycle $i."
    exit 0
  fi
  if [[ -f .saeed/CONVERGED ]]; then
    echo "SAEED: CONVERGED. Nothing worthwhile left to improve. Stopping at cycle $i."
    cat .saeed/CONVERGED || true
    exit 0
  fi

  echo "=== SAEED cycle $i/$MAX_CYCLES ==="
  # Headless invocation. --permission-mode is set so the team can edit files unattended;
  # review the plugin's guardrails before granting broad permissions.
  claude -p "/saeed:improve" --permission-mode acceptEdits || {
    echo "SAEED: cycle $i failed (claude exited non-zero). Stopping for inspection."
    exit 1
  }

  [[ "$SLEEP_SECONDS" -gt 0 ]] && sleep "$SLEEP_SECONDS"
done

echo "SAEED: reached MAX_CYCLES ($MAX_CYCLES) without convergence. Stopping."
