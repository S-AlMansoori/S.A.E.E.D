#!/usr/bin/env bash
#
# guard-git-bypass.sh — PreToolUse(Bash) guardrail (absorbed from ECC's
# block-no-verify hook, reimplemented in SAEED's bash+python3 house style).
#
# WHY: SAEED's self-governance protocol lists "the team never disables its
# own review/test/security gates" among the untouchables. This hook is the
# mechanical floor under that rule for git: it blocks any attempt to bypass
# git hooks — `--no-verify` / commit's `-n` on gate-relevant subcommands,
# and `core.hooksPath` overrides that would silence hooks entirely.
#
# CONTRACT (Claude Code hook semantics):
#   stdin  — PreToolUse JSON: {"tool_input": {"command": "..."}, ...}
#   exit 0 — allow (empty stdout; nothing injected)
#   exit 2 — BLOCK; the stderr text is fed back to the model as the reason
#   Fail-open by design: unparseable input or a missing python3 allows the
#   call rather than bricking every Bash invocation.
#
# KNOWN LIMITS (accepted): quoted strings are stripped before matching, so a
# commit message that *mentions* --no-verify is not a false positive; an
# adversarial multi-layer shell quoting could still slip through — this is a
# guardrail against habit, not a sandbox.

PY="$(command -v python3 || true)"
if [[ -z "${PY}" ]]; then
  exit 0
fi

# The heredoc below occupies stdin for the python program itself, so the hook
# payload is captured to a temp file first and passed by path (argv), exactly
# like scripts/validate-fleet.sh passes its repo root.
PAYLOAD="$(mktemp)"
trap 'rm -f "${PAYLOAD}"' EXIT
cat > "${PAYLOAD}" 2>/dev/null || true

"${PY}" - "${PAYLOAD}" <<'PYEOF'
import json
import re
import sys

try:
    with open(sys.argv[1], encoding="utf-8") as f:
        data = json.load(f)
except Exception:
    sys.exit(0)

cmd = (data.get("tool_input") or {}).get("command") or ""
if not isinstance(cmd, str) or not cmd.strip():
    sys.exit(0)


def strip_quoted(s: str) -> str:
    """Blank out single- and double-quoted segments so flags inside commit
    messages / heredoc-ish strings don't trigger the guard."""
    s = re.sub(r"'[^']*'", " ", s)
    s = re.sub(r'"(?:[^"\\]|\\.)*"', " ", s)
    return s


bare = strip_quoted(cmd)


def block(reason: str) -> None:
    print(reason, file=sys.stderr)
    sys.exit(2)


# --- 1. --no-verify (and commit's -n family) on gate-relevant subcommands ---
GIT_SUB = re.compile(
    r"\bgit\b(?:\s+-[cC]\s*\S+|\s+--[\w=./-]+)*\s+(commit|push|merge|rebase|cherry-pick|am)\b"
)
for m in GIT_SUB.finditer(bare):
    segment = bare[m.start():]
    stop = re.search(r"[;|&\n]", segment)
    if stop:
        segment = segment[: stop.start()]
    sub = m.group(1)
    if re.search(r"(^|\s)--no-verify\b", segment):
        block(
            f"BLOCKED: `--no-verify` with `git {sub}` is not allowed. SAEED never "
            "bypasses its own gates (skills/self-governance/SKILL.md — the untouchables). "
            "Run the hooks and fix what they catch; if a hook itself is broken, fix the "
            "hook or park the problem under '## Awaiting operator' in .saeed/queue.md."
        )
    # For `git commit`, -n IS --no-verify (also inside combined valueless-flag
    # clusters like -an). Other subcommands' -n means dry-run, so commit only.
    if sub == "commit" and re.search(r"(^|\s)-(?=[amnpqsv]*n)[amnpqsv]+\b", segment):
        block(
            "BLOCKED: `git commit -n` (no-verify) is not allowed — same rule as "
            "`--no-verify`: SAEED never bypasses its own gates. Run the hooks and fix "
            "what they catch instead."
        )

# --- 2. core.hooksPath overrides (silences hooks wholesale) ---
if re.search(r"-c\s*core\.hooksPath=", bare, re.IGNORECASE):
    block(
        "BLOCKED: overriding `core.hooksPath` on the command line disables the repo's "
        "git hooks — SAEED never weakens its own gates. Run the real hooks."
    )
config_m = re.search(r"\bgit\b[^;|&\n]*\bconfig\b([^;|&\n]*)\bcore\.hooksPath\b([^;|&\n]*)", bare, re.IGNORECASE)
if config_m:
    flags = config_m.group(1) + config_m.group(2)
    # Reading or unsetting the override is fine; setting it is not.
    if not re.search(r"--get\b|--unset", flags):
        block(
            "BLOCKED: setting `core.hooksPath` via git config disables the repo's git "
            "hooks — SAEED never weakens its own gates. If a hook is genuinely broken, "
            "fix it or park the change for the operator."
        )

sys.exit(0)
PYEOF
exit $?
