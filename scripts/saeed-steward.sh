#!/usr/bin/env bash
# SAEED stewardship heartbeat — keeps a CONVERGED project alive indefinitely.
#
# WHY THIS EXISTS (cycle 5, the retirement handover)
#   saeed-loop.sh drives a repo TO convergence and rightly stops there — but
#   "converged" must not mean "dead". This script is the post-convergence
#   heartbeat: one lightweight pass that re-runs the executable gates, checks
#   the reopen/revisit triggers written into .saeed/CONVERGED and the queue,
#   and wakes the full loop ONLY when one fires. Semantics are defined in
#   skills/self-governance/SKILL.md ("Stewardship") and /saeed:improve's
#   headless behavior: it never stalls to ask an absent operator; approvals it
#   can't get are parked under "## Awaiting operator" in .saeed/queue.md.
#
#   Sessions cannot wake themselves — put this on a scheduler. Weekly example:
#     0 9 * * 1  /path/to/S.A.E.E.D./scripts/saeed-steward.sh /path/to/repo >> "$HOME/saeed-steward.log" 2>&1
#
# Usage:  scripts/saeed-steward.sh /path/to/target-repo
# Requires the Claude Code CLI (`claude`) on PATH and the SAEED plugin installed.
# ⚠️ Runs unattended and may edit files — only point it at a repo under git.
set -euo pipefail

REPO="${1:-$(pwd)}"
cd "$REPO"
mkdir -p .saeed

if [[ -f .saeed/STOP ]]; then
  echo "SAEED steward: STOP file present — standing down (delete .saeed/STOP to resume)."
  exit 0
fi

if [[ -f .saeed/CONVERGED ]]; then
  echo "SAEED steward: converged repo — running a heartbeat pass (gates + reopen triggers)."
else
  echo "SAEED steward: repo not converged — running one normal improvement pass."
fi

# One pass. On a converged repo the headless /saeed:improve runs steward
# semantics (never asks whether to override; reopens only on a fired trigger
# or a red gate, logged); otherwise it is a normal improvement pass.
claude -p "/saeed:improve" --permission-mode acceptEdits || {
  echo "SAEED steward: pass failed (claude exited non-zero) — inspect before the next beat."
  exit 1
}

echo "SAEED steward: beat complete."
