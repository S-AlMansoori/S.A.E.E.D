#!/usr/bin/env bash
#
# guard-attribution-canon.sh — PreToolUse(Write|Edit|MultiEdit) + PreToolUse(Bash)
# guardrail. The mechanical floor under the Arabic half of
# skills/attribution/SKILL.md.
#
# WHY THIS EXISTS
#   The company's Arabic name is a WORD — نبض ("pulse") — not a spelling of the
#   Latin letters N-A-B-A-D. Field defect: several generated surfaces shipped
#   `ناباد`, a letter-for-letter transliteration of the English "NABAD", instead
#   of the real name. The mechanism is structural, not careless: the Arabic
#   string lived in exactly one canon file while every other surface only said
#   "carry the NABAD credit, bilingual". An agent writing an Arabic surface
#   without loading that canon has nothing to copy, so it RE-DERIVES the name —
#   and the only derivation available from Latin "NABAD" is a transliteration.
#   Nothing forbade it and nothing detected it, so it shipped.
#
#   A transliterated company name is a brand defect of the worst kind on a
#   bilingual surface: it reads as machine output to every Arabic reader, and it
#   is the client's own name that is misspelled.
#
# WHAT IT ENFORCES (deterministic; no judgment)
#   Written text — Write/Edit/MultiEdit content, and Bash commands that write
#   (redirect / tee / sed -i / heredoc) — may not contain:
#     Tier A, banned anywhere: forms that are not Arabic words at all and can
#       only be a botched transliteration of the name (ناباد, نباد, نابد, ...).
#     Tier B, banned in company-name position only: real Arabic words that are
#       simply not the name (نابض "pulsating", النبض, نبضة). These are legitimate
#       prose elsewhere — SAEED's own docs speak of `نبض الوصاية` — so they are
#       flagged only when adjacent to `تطوير` or `لحلول`, i.e. used AS the name.
#
#   Matching is Arabic-word-boundary anchored, never bare substring: `نباد` is a
#   substring of the everyday verbs `نبادل` ("we exchange") and `نبادر` ("we
#   initiate"), and blocking those would be a false positive on ordinary copy.
#
# EXEMPT PATHS (the ban list has to be writable somewhere)
#   skills/attribution/SKILL.md, scripts/validate-fleet.sh, this hook, and
#   CHANGELOG.md are the registry of wrong forms — they must be able to NAME
#   them. Every other file in every repo SAEED touches is gated.
#
# CONTRACT (Claude Code hook semantics)
#   stdin  — PreToolUse JSON: {"tool_name": "...", "tool_input": {...}, ...}
#            registered on BOTH the "Bash" and "Write|Edit|MultiEdit" matcher
#            groups in hooks/hooks.json; the script branches on tool_name.
#   exit 0 — allow; exit 2 — BLOCK (stderr is fed back to the model as the reason)
#   Fail-open on unparseable input / missing python3, like every guard here.
#
# KNOWN LIMITS (accepted): the Bash channel is a secondary net and detects
# "this command writes" by segment heuristics, not shell semantics — a
# `python3 -c "open(...,'w')..."` payload slips through. The tool-call channel
# is the primary gate and is exact. Reads are never blocked: `grep ناباد -r .`
# is exactly how an operator diagnoses this defect and must keep working.

PY="$(command -v python3 || true)"
if [[ -z "${PY}" ]]; then
  exit 0
fi

# The heredoc below occupies stdin for the python program itself, so the hook
# payload is captured to a temp file first and passed by path (argv), exactly
# like the other guard hooks in this directory.
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

tool_name = data.get("tool_name") or ""
tool_input = data.get("tool_input") or {}
if not isinstance(tool_input, dict):
    sys.exit(0)

# --------------------------------------------------------------------------
# The canon (skills/attribution/SKILL.md, "Canonical strings")
# --------------------------------------------------------------------------
CANON_AR_NAME = "نبض"
CANON_AR_LINE = "تطوير نبض لحلول الكمبيوتر ذ.م.م."

# Arabic-letter class, used to anchor every match at a word boundary so that
# `نباد` does not fire inside `نبادل` / `نبادر`.
AR = "؀-ۿ"
BL = f"(?<![{AR}])"
BR = f"(?![{AR}])"

# Tier A — not Arabic words; only ever a transliteration of Latin "NABAD".
ALWAYS_WRONG = ["ناباد", "نباد", "نابد", "ناباض", "نابااد", "نااباد", "نبظ", "نبأد"]

# Tier B — real Arabic words, wrong only when used AS the company name.
WRONG_AS_NAME = ["نابض", "النبض", "نبضة", "نبضه"]

# Separators tolerated between the name and its surrounding context: spaces,
# markdown emphasis, brackets, and the bidi control marks that RTL copy carries.
SEP = r"(?:[\s*_`~()\[\]«»\"'،,‎‏؜‪-‮]|<[^>]{0,40}>){0,8}"

ALWAYS_RE = re.compile("|".join(f"{BL}{re.escape(v)}{BR}" for v in ALWAYS_WRONG))
AS_NAME_RES = [
    re.compile(
        f"(?:تطوير{SEP}(?:{BL}(?:" + "|".join(re.escape(v) for v in WRONG_AS_NAME) + f"){BR}))"
        f"|(?:{BL}(?:" + "|".join(re.escape(v) for v in WRONG_AS_NAME) + f"){BR}{SEP}لحلول)"
    )
]

# --------------------------------------------------------------------------
# Files that ARE the ban list — they have to be able to name the wrong forms.
# --------------------------------------------------------------------------
EXEMPT_SUFFIXES = (
    "skills/attribution/SKILL.md",
    "scripts/validate-fleet.sh",
    "hooks/guard-attribution-canon.sh",
    "CHANGELOG.md",
)


def is_exempt_path(path):
    p = (path or "").replace("\\", "/")
    return any(p.endswith(suffix) for suffix in EXEMPT_SUFFIXES)


# A Bash command only matters if it WRITES. Reading (grep/cat/rg) must stay
# allowed — diagnosing this very defect starts with grepping for the bad form.
WRITES_RE = re.compile(
    r"(?:>>?\s*[^\s|&;]|\|\s*tee\b|\btee\b|\bsed\b[^|;&]*\s-i|\bperl\b[^|;&]*\s-i"
    r"|\bawk\b[^|;&]*>|<<[-']?\s*['\"]?[A-Za-z_]|\bpatch\b|\bapply\b)"
)


def written_text():
    """Return the text this tool call would WRITE, or None if it writes none."""
    if tool_name == "Bash":
        cmd = tool_input.get("command")
        if not isinstance(cmd, str) or not cmd.strip():
            return None
        if is_exempt_path(cmd) or any(s in cmd for s in EXEMPT_SUFFIXES):
            return None
        if not WRITES_RE.search(cmd):
            return None
        return cmd
    # Write / Edit / MultiEdit
    if is_exempt_path(tool_input.get("file_path")):
        return None
    parts = []
    for key in ("content", "new_string"):
        val = tool_input.get(key)
        if isinstance(val, str):
            parts.append(val)
    edits = tool_input.get("edits")
    if isinstance(edits, list):
        for edit in edits:
            if isinstance(edit, dict) and isinstance(edit.get("new_string"), str):
                parts.append(edit["new_string"])
    return "\n".join(parts) if parts else None


text = written_text()
if not text:
    sys.exit(0)

found = None
m = ALWAYS_RE.search(text)
if m:
    found = m.group(0)
else:
    for rx in AS_NAME_RES:
        m = rx.search(text)
        if m:
            found = m.group(0).strip()
            break

if not found:
    sys.exit(0)

print(
    f"BLOCKED: this write spells the company's Arabic name as «{found}». "
    f"The name is «{CANON_AR_NAME}» — an Arabic word meaning \"pulse\", NOT a "
    f"transliteration of the Latin letters N-A-B-A-D. Never render the English "
    f"name into Arabic letters; copy the canonical string verbatim:\n"
    f"    {CANON_AR_LINE}\n"
    f"(skills/attribution/SKILL.md — 'Canonical strings' and 'The Arabic name is "
    f"a word, never a transliteration'.) Fix the string and write again.",
    file=sys.stderr,
)
sys.exit(2)
PYEOF
exit $?
