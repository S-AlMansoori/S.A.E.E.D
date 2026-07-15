#!/usr/bin/env bash
#
# guard-config-protection.sh — PreToolUse(Write|Edit|MultiEdit) guardrail
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
#   stdin  — PreToolUse JSON: {"tool_input": {"file_path": "..."}, ...}
#   exit 0 — allow; exit 2 — BLOCK (stderr fed to the model)
#   Fail-open on unparseable input / missing python3.
#
# The protected set mirrors ECC's deliberately: linter/formatter configs
# only. pyproject.toml and tsconfig.json are NOT protected — they carry
# build/runtime config too, and blocking them breaks legitimate work.

PY="$(command -v python3 || true)"
if [[ -z "${PY}" ]]; then
  exit 0
fi

# The heredoc below occupies stdin for the python program itself, so the hook
# payload is captured to a temp file first and passed by path (argv).
PAYLOAD="$(mktemp)"
trap 'rm -f "${PAYLOAD}"' EXIT
cat > "${PAYLOAD}" 2>/dev/null || true

"${PY}" - "${PAYLOAD}" <<'PYEOF'
import json
import os
import sys

try:
    with open(sys.argv[1], encoding="utf-8") as f:
        data = json.load(f)
except Exception:
    sys.exit(0)

file_path = (data.get("tool_input") or {}).get("file_path") or ""
if not isinstance(file_path, str) or not file_path.strip():
    sys.exit(0)

PROTECTED = {
    # eslint
    ".eslintrc", ".eslintrc.js", ".eslintrc.cjs", ".eslintrc.json",
    ".eslintrc.yml", ".eslintrc.yaml",
    "eslint.config.js", "eslint.config.mjs", "eslint.config.cjs", "eslint.config.ts",
    # prettier
    ".prettierrc", ".prettierrc.js", ".prettierrc.cjs", ".prettierrc.json",
    ".prettierrc.yml", ".prettierrc.yaml", ".prettierrc.toml",
    "prettier.config.js", "prettier.config.cjs", "prettier.config.mjs",
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

base = os.path.basename(file_path)
if base not in PROTECTED:
    sys.exit(0)

# First-time creation is legitimate scaffolding; only modification is gated.
try:
    exists = os.path.lexists(file_path)
except OSError:
    exists = True  # can't inspect it -> fail closed for a protected name

if not exists:
    sys.exit(0)

print(
    f"BLOCKED: modifying the existing lint/format config `{base}` is gate-weakening — "
    "a SAEED untouchable (skills/self-governance/SKILL.md). Fix the code the gate is "
    "complaining about, not the gate. If the config itself is genuinely wrong, propose "
    "the exact change to the operator (or park it under '## Awaiting operator' in "
    ".saeed/queue.md) instead of silently loosening it.",
    file=sys.stderr,
)
sys.exit(2)
PYEOF
exit $?
