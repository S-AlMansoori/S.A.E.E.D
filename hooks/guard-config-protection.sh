#!/usr/bin/env bash
#
# guard-config-protection.sh — PreToolUse(Write|Edit|MultiEdit|apply_patch|Bash)
# guardrail
# (absorbed from ECC's config-protection hook, reimplemented in SAEED's
# bash+python3 house style).
#
# WHY: when a linter or formatter blocks progress, the cheap move is to edit
# the config instead of the code. That is gate-weakening — a SAEED
# untouchable. This hook blocks MODIFICATION of an existing lint/format
# config while still allowing first-time CREATION (scaffolding a new project
# legitimately writes these files).
#
# CONTRACT:
#   stdin  — PreToolUse JSON. Claude Code: {"tool_name": "Write|Edit|MultiEdit",
#            "tool_input": {"file_path": "..."}}. Codex: {"tool_name":
#            "apply_patch", "tool_input": {"command": "*** Begin Patch..."}},
#            normalized by hooks/lib/hookio.py into per-file records.
#            Bash: {"tool_input": {"command": "..."}} — shell writes into a
#            protected file (redirect, tee, sed -i, truncate, rm, mv, cp) are
#            the same modification by another channel. Reads are never gated.
#   exit 0 — allow; exit 2 — BLOCK (stderr fed to the model)
#   Fail-open on unparseable input / missing python3 (with a one-line stderr
#   warning, so a silently disabled guard is at least visible).
#
# The protected set mirrors ECC's deliberately: linter/formatter configs
# only. pyproject.toml and tsconfig.json are NOT protected — they carry
# build/runtime config too, and blocking them breaks legitimate work.
# Names compare case-insensitively: APFS/NTFS resolve `.ESLintrc.json` to the
# same file, so a case variant must not be a way around the list.

PY="$(command -v python3 || true)"
if [[ -z "${PY}" ]]; then
  echo "SAEED guard-config-protection: python3 not found; guard inactive (fail-open)." >&2
  exit 0
fi
HOOK_LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib"

# The heredoc below occupies stdin for the python program itself, so the hook
# payload is captured to a temp file first and passed by path (argv).
PAYLOAD="$(mktemp)"
trap 'rm -f "${PAYLOAD}"' EXIT
cat > "${PAYLOAD}" 2>/dev/null || true

"${PY}" - "${PAYLOAD}" "${HOOK_LIB}" <<'PYEOF'
import json
import os
import sys

sys.path.insert(0, sys.argv[2] if len(sys.argv) > 2 else "")
try:
    from hookio import parse_apply_patch, patch_text, write_targets
except ImportError:
    print("SAEED guard-config-protection: hooks/lib unavailable; guard inactive (fail-open).", file=sys.stderr)
    sys.exit(0)

try:
    with open(sys.argv[1], encoding="utf-8") as f:
        data = json.load(f)
except Exception:
    sys.exit(0)
if not isinstance(data, dict) or not isinstance(data.get("tool_input") or {}, dict):
    sys.exit(0)
tool_name = data.get("tool_name") or ""
tool_input = data.get("tool_input") or {}
CWD = data.get("cwd") if isinstance(data.get("cwd"), str) and data.get("cwd") else os.getcwd()

PROTECTED = {
    # eslint
    ".eslintrc", ".eslintrc.js", ".eslintrc.cjs", ".eslintrc.json",
    ".eslintrc.yml", ".eslintrc.yaml", ".eslintignore",
    "eslint.config.js", "eslint.config.mjs", "eslint.config.cjs", "eslint.config.ts",
    "eslint.config.mts", "eslint.config.cts",
    # prettier
    ".prettierrc", ".prettierrc.js", ".prettierrc.cjs", ".prettierrc.json",
    ".prettierrc.yml", ".prettierrc.yaml", ".prettierrc.toml", ".prettierignore",
    "prettier.config.js", "prettier.config.cjs", "prettier.config.mjs", "prettier.config.ts",
    # biome
    "biome.json", "biome.jsonc",
    # python linters/formatters
    "ruff.toml", ".ruff.toml", ".flake8",
    # stylelint
    ".stylelintrc", ".stylelintrc.js", ".stylelintrc.cjs", ".stylelintrc.json",
    ".stylelintrc.yml", ".stylelintrc.yaml",
    "stylelint.config.js", "stylelint.config.cjs", "stylelint.config.mjs",
    # markdownlint
    ".markdownlint.json", ".markdownlint.jsonc", ".markdownlint.yaml", ".markdownlint.yml",
}


def exists(path):
    full = path if os.path.isabs(path) else os.path.join(CWD, path)
    try:
        return os.path.lexists(full)
    except OSError:
        return True  # can't inspect it -> fail closed for a protected name


# (path, channel, exists-override) triples this call would modify. First-time
# creation is legitimate scaffolding, so only paths that already exist are
# gated — on every channel, including Codex `*** Add File:` and shell `>`.
touched = []
if tool_name == "Bash":
    cmd = tool_input.get("command") or ""
    if isinstance(cmd, str) and cmd.strip():
        touched = [(t, f"shell {kind}", None) for t, kind in write_targets(cmd)]
elif tool_name == "apply_patch":
    touched = [(pth, f"apply_patch {op}", True if op in ("update", "delete") else None)
               for pth, op, _ in parse_apply_patch(patch_text(tool_input))]
else:
    fp = tool_input.get("file_path")
    if isinstance(fp, str) and fp.strip():
        touched = [(fp, tool_name or "edit", None)]

for path, channel, known in touched:
    base = os.path.basename(path.rstrip("/"))
    if base.lower() in PROTECTED and (known if known is not None else exists(path)):
        print(
            f"BLOCKED: modifying the existing lint/format config `{base}` ({channel}) is "
            "gate-weakening — a SAEED untouchable (skills/self-governance/SKILL.md). Fix the "
            "code the gate is complaining about, not the gate. If the config itself is "
            "genuinely wrong, propose the exact change to the operator (or park it under "
            "'## Awaiting operator' in .saeed/queue.md) instead of silently loosening it.",
            file=sys.stderr,
        )
        sys.exit(2)

sys.exit(0)
PYEOF
exit $?
