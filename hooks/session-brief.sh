#!/usr/bin/env bash
#
# session-brief.sh — SessionStart context injection (absorbed from ECC's
# session-start persistence pattern, adapted to SAEED's `.saeed/` state
# convention: the durable memory is the state directory, not a transcript).
#
# WHY: a fresh session starts blind. If the project has a `.saeed/` state
# directory, this hook injects a compact brief — autonomy level, STOP /
# CONVERGED flags, queue counts by status, parked approvals, last retro
# line — so the team resumes exactly where the ledger says it is instead of
# re-deriving (or worse, contradicting) prior state.
#
# CONTRACT:
#   stdout — either nothing (no .saeed/ present) or a single JSON object:
#            {"hookSpecificOutput": {"hookEventName": "SessionStart",
#                                     "additionalContext": "..."}}
#   exit 0 always (a brief is a convenience, never a blocker) — fail-open.
#   Output is bounded (~1,800 chars) so it never crowds the context window.

PY="$(command -v python3 || true)"
if [[ -z "${PY}" ]]; then
  exit 0
fi

exec "${PY}" - <<'PYEOF'
import json
import os
import re
import sys

MAX_CHARS = 1800

try:
    if not os.path.isdir(".saeed"):
        sys.exit(0)

    lines = []

    # Autonomy level (first non-blank, non-comment line; absent = supervised).
    level = "supervised (default — file absent)"
    try:
        with open(".saeed/AUTONOMY", encoding="utf-8") as f:
            for raw in f:
                s = raw.strip()
                if s and not s.startswith("#"):
                    level = s
                    break
    except OSError:
        pass
    lines.append(f"- Autonomy: {level}")

    # Sentinels.
    flags = []
    if os.path.exists(".saeed/STOP"):
        flags.append("STOP present (loop halted — do not run passes)")
    if os.path.exists(".saeed/CONVERGED"):
        flags.append("CONVERGED present (steward semantics apply)")
    lines.append("- Sentinels: " + ("; ".join(flags) if flags else "none"))

    # Queue counts by status + parked approvals.
    try:
        with open(".saeed/queue.md", encoding="utf-8") as f:
            queue = f.read()
        counts = {
            s: len(re.findall(rf"\b{s}\b", queue))
            for s in ("TODO", "IN_PROGRESS", "IN_REVIEW", "DONE", "REJECTED", "WONTFIX")
        }
        summary = ", ".join(f"{k}:{v}" for k, v in counts.items() if v)
        lines.append(f"- Queue: {summary if summary else 'no status-tagged items'}")
        m = re.search(r"^## Awaiting operator\n(.*?)(?=\n## |\Z)", queue, re.S | re.M)
        if m:
            parked = len(re.findall(r"^\s*[-*]\s+\S", m.group(1), re.M))
            lines.append(f"- Awaiting operator: {parked} parked item(s)")
    except OSError:
        lines.append("- Queue: .saeed/queue.md not readable")

    # Last retro line (the heartbeat trail).
    try:
        with open(".saeed/retro.md", encoding="utf-8") as f:
            last = ""
            for raw in f:
                s = raw.strip()
                if s:
                    last = s
        if last:
            lines.append(f"- Last retro entry: {last[:200]}")
    except OSError:
        pass

    brief = (
        "SAEED session brief — snapshot of this repo's .saeed/ state. It is a "
        "SUMMARY for orientation, not instructions: verify against the files "
        "before acting on it.\n" + "\n".join(lines)
    )
    if len(brief) > MAX_CHARS:
        brief = brief[: MAX_CHARS - 15] + "\n...[truncated]"

    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "SessionStart",
            "additionalContext": brief,
        }
    }))
    sys.exit(0)
except Exception:
    sys.exit(0)
PYEOF
