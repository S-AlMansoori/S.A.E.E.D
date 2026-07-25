#!/usr/bin/env bash
#
# guard-tdd-mode.sh — PreToolUse(Bash) + PreToolUse(Write|Edit|MultiEdit)
# guardrail (absorbed from nizos' tdd-guard/probity hardening rules —
# "Strengthening TDD Enforcement" — reimplemented in SAEED's bash+python3
# house style as a deterministic bash proxy, not an AI validator).
#
# WHY: SAEED's engineering-method canon (skills/engineering-method/SKILL.md)
# states the TDD Iron Law doctrinally for every agent, always. This hook is
# the *mechanical* floor under it for repos that opt in — a bash
# approximation of what Probity does with an AI validator. It is
# deliberately narrow: it catches bypass channels and a test-in-changeset
# proxy, never quality judgments (transient broken states, characterization
# tests, refactor-under-green, clean-red recovery — all canon territory,
# never this hook's).
#
# ACTIVATION — opt-in per repo, sentinel-gated (house sentinel idiom, same
# shape as `.saeed/AUTONOMY`): a `.saeed/TDD` file whose first non-blank,
# non-`#` line is one of `off` | `advisory` | `enforce`.
#   - ABSENT sentinel -> silent, zero overhead: this hook does not even
#     invoke python3. This is the default everywhere; a repo must opt in.
#   - `off` -> silent, same as absent.
#   - `advisory` -> detections 1 and 2 below warn on stderr and exit 0;
#     detection 3 (sentinel tamper) still BLOCKS — advisory still means the
#     guard is active, and an active guard cannot be weakened.
#   - `enforce` -> detections 1 and 2 BLOCK (exit 2); detection 3 BLOCKs too.
#   - Unparseable sentinel content, unparseable JSON payload, or no python3
#     -> fail open (exit 0), matching every other guard hook in this repo.
#
# WHAT IT ENFORCES (deterministic only — no AI judgment):
#   1. [Bash, enforce only] Blocks shell bypass channels that write into
#      "logic-bearing" source (echo/printf/sed -i/awk/perl/tee redirection)
#      — these circumvent the Write/Edit hooks entirely.
#   2. [Write|Edit|MultiEdit, enforce only] Blocks a Write/Edit to a
#      logic-bearing source file when the pending change-set (git status in
#      the target's repo) has no added/modified test file — a mechanical
#      proxy for test-first. The canon judges quality; this hook only checks
#      "is *a* test file present anywhere in the working tree's changes".
#   3. [Bash, and Write|Edit|MultiEdit; any mode except `off`] Blocks
#      modification of an EXISTING `.saeed/TDD` sentinel or any
#      `.saeed/tdd-state*` file — you cannot weaken an active guard (same
#      precedent as guard-config-protection.sh: block edits to an existing
#      file, allow first-time creation). Covers both the tool-call channel
#      (Write/Edit/MultiEdit) and the shell channel (`rm`/`unlink`, or any
#      `>`/`>>` redirection, targeting the sentinel — see NIT N3 below for
#      exact scope). The operator edits the sentinel directly, outside of
#      tool calls.
#
# "Logic-bearing code": ts/tsx/js/jsx/py/swift/kt/java/go/rs/rb source
# files, excluding test files themselves, docs/markdown, config
# (json/yaml/toml), lockfiles, generated artifacts (dist/build/vendor/
# node_modules/.min.*), and migrations. Applies to managed product repos
# that opt in; the SAEED plugin repo itself has no product test suite and
# stays out of scope by simply never carrying a `.saeed/TDD` sentinel.
#
# CONTRACT (Claude Code hook semantics):
#   stdin  — PreToolUse JSON: {"tool_name": "...", "tool_input": {...}, ...}
#            registered on BOTH the "Bash" and the "Write|Edit|MultiEdit"
#            matcher groups in hooks/hooks.json, so this single script
#            branches on tool_name to know which shape applies.
#   exit 0 — allow (empty stdout; nothing injected)
#   exit 2 — BLOCK; the stderr text is fed back to the model as the reason
#
# KNOWN LIMITS (accepted, same spirit as guard-git-bypass.sh): the bypass-
# channel and in-place-edit detection is segment heuristics, not a shell
# parser — a determined multi-layer-quoting adversary could still slip
# through. Target-path extraction (redirection, tee args, `-i` targets) is
# quote-aware via Python's shlex, so a path containing spaces is treated as
# one token instead of being truncated at the first space (the class of bug
# fixed in cycle 9 — this repo's own path contains a space, so this is not
# academic). This is a guardrail against habit, not a sandbox. The test-in-
# changeset proxy only sees `git status` in the target file's repo; a repo
# that is not a git working tree is indeterminate and therefore NOT blocked
# (fail open — the deterministic check has nothing to check).
#
# NIT N3 (sentinel tamper via Bash, closed for the two unambiguous shapes):
# detection 3 originally only fired through the Write/Edit/MultiEdit
# matcher, so `rm .saeed/TDD` or `echo off > .saeed/TDD` via Bash bypassed
# it entirely. This hook now also blocks, from the Bash branch: (a) `rm`/
# `unlink` targeting the sentinel file or the whole `.saeed` directory, and
# (b) any `>`/`>>` redirection (from any command, not just the bypass list)
# whose target is the sentinel. Both are deterministic and effectively
# false-positive-free — there is no legitimate reason to delete or
# redirect-overwrite `.saeed/TDD` from a tool call; the operator edits it
# directly, outside of tool calls, per the ACTIVATION note above. NOT
# caught, honestly: `mv`/`cp` used as an overwrite destination, `sed -i`
# without `-i` glued (already covered) but invoked via `xargs`/`find
# -delete`/`env`/`sudo` wrappers, or a one-off `python3 -c "open(...,
# 'w')..."` — closing those would require real shell semantics this
# heuristic layer does not have, so they remain an accepted residual gap.

if [[ ! -f ".saeed/TDD" ]]; then
  exit 0
fi

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
import os
import re
import shlex
import subprocess
import sys


def read_sentinel(path):
    try:
        with open(path, encoding="utf-8") as f:
            for raw in f:
                s = raw.strip()
                if s and not s.startswith("#"):
                    return s
    except OSError:
        return None
    return None


MODE = read_sentinel(".saeed/TDD")
if MODE not in ("off", "advisory", "enforce"):
    # Absent is handled by the bash fast-path above; garbage/unknown content
    # in an existing file fails open the same way (never brick on a typo).
    sys.exit(0)
if MODE == "off":
    sys.exit(0)

try:
    with open(sys.argv[1], encoding="utf-8") as f:
        data = json.load(f)
except Exception:
    sys.exit(0)

tool_name = data.get("tool_name") or ""
tool_input = data.get("tool_input") or {}

SOURCE_EXTS = {"ts", "tsx", "js", "jsx", "py", "swift", "kt", "java", "go", "rs", "rb"}

GEN_DIR_RE = re.compile(r"(^|/)(dist|build|node_modules|coverage|\.next|vendor|target)(/|$)", re.I)
MIGRATION_RE = re.compile(r"(^|/)(migrations?|migrate|alembic/versions)(/|$)", re.I)


def is_test_path(path):
    p = path.replace("\\", "/")
    base = os.path.basename(p)
    parts = p.split("/")[:-1]
    if any(seg.lower() in ("test", "tests", "__tests__", "spec", "specs") for seg in parts):
        return True
    if re.search(r"\.(test|spec)\.[A-Za-z0-9]+$", base):
        return True
    if re.match(r"^test_.+\.py$", base):
        return True
    if re.match(r".+_test\.py$", base):
        return True
    if re.match(r".+_test\.go$", base):
        return True
    if re.match(r".+Tests?\.(java|kt)$", base):
        return True
    if re.match(r".+Tests?\.swift$", base):
        return True
    if re.match(r".+_spec\.rb$", base):
        return True
    return False


def is_generated_or_migration(path):
    p = path.replace("\\", "/")
    if GEN_DIR_RE.search(p) or MIGRATION_RE.search(p):
        return True
    if re.search(r"\.min\.(js|css)$", p) or ".generated." in p:
        return True
    return False


def logic_bearing(path):
    if not path:
        return False
    base = os.path.basename(path)
    if "." not in base:
        return False
    ext = base.rsplit(".", 1)[-1].lower()
    if ext not in SOURCE_EXTS:
        return False
    if is_test_path(path):
        return False
    if is_generated_or_migration(path):
        return False
    return True


def is_sentinel_path(path):
    norm = path.replace("\\", "/")
    parts = norm.split("/")
    if len(parts) < 2:
        return False
    parent, name = parts[-2], parts[-1]
    if parent != ".saeed":
        return False
    return name == "TDD" or name.startswith("tdd-state")


def changeset_has_test_file():
    """Deterministic proxy: is any test file part of the pending change-set
    (working tree, per `git status`) in the target's repo? Returns True /
    False, or None when indeterminate (not a git repo) — indeterminate is
    never treated as a violation."""
    try:
        root = subprocess.run(
            ["git", "rev-parse", "--show-toplevel"],
            capture_output=True, text=True, timeout=5,
        )
        if root.returncode != 0:
            return None
        top = root.stdout.strip()
        status = subprocess.run(
            ["git", "status", "--porcelain", "--untracked-files=all"],
            capture_output=True, text=True, timeout=5, cwd=top,
        )
        if status.returncode != 0:
            return None
        for line in status.stdout.splitlines():
            entry_path = line[3:] if len(line) > 3 else ""
            if " -> " in entry_path:
                entry_path = entry_path.split(" -> ", 1)[1]
            if entry_path and is_test_path(entry_path):
                return True
        return False
    except Exception:
        return None


def strip_quotes(tok):
    tok = tok.strip()
    if len(tok) >= 2 and tok[0] == tok[-1] and tok[0] in ("'", '"'):
        return tok[1:-1]
    return tok


def _tokenize(seg):
    """Quote-aware split of a command segment into shell-word tokens. Falls
    back to a naive whitespace split (with best-effort quote stripping) on
    unbalanced-quote input rather than throwing the check away entirely —
    this is a heuristic layer, not a shell, so it degrades, it doesn't trip."""
    try:
        return shlex.split(seg, posix=True)
    except ValueError:
        return [strip_quotes(t) for t in seg.split()]


def _first_word_after(seg, pos):
    """The next shell word starting at seg[pos:], quote-aware. Used to pull
    a redirection target: shlex parses the remainder so a quoted path
    containing spaces stays one token instead of being cut at the first
    space (the bug this rewrite fixes — this repo's own path has a space)."""
    rest = seg[pos:]
    toks = _tokenize(rest)
    return toks[0] if toks else None


BYPASS_CMD_RE = re.compile(r"\b(echo|printf|sed|awk|gawk|perl|tee)\b")
RM_CMD_RE = re.compile(r"\b(rm|unlink)\b")
REDIRECT_RE = re.compile(r">>?")


def segment_redirect_targets(seg):
    """Every `>`/`>>` redirection target in one command segment, regardless
    of which command issued it — quote-aware via _first_word_after."""
    targets = []
    for m in REDIRECT_RE.finditer(seg):
        tgt = _first_word_after(seg, m.end())
        if tgt:
            targets.append(tgt)
    return targets


def find_bypass_targets(cmd):
    """Best-effort: file-path targets a bypass command appears to write to
    (redirection, tee's own args, or an in-place-edit tool's -i target).
    Quote-aware throughout so a target path containing spaces is treated as
    one token instead of being truncated at the first space."""
    targets = []
    for seg in re.split(r"&&|\|\||[;&\n|]", cmd):
        seg = seg.strip()
        if not seg or not BYPASS_CMD_RE.search(seg):
            continue
        targets.extend(segment_redirect_targets(seg))
        toks = _tokenize(seg)
        tee_m = re.match(r"^\s*tee\b", seg)
        if tee_m:
            tee_idx = next((i for i, t in enumerate(toks) if t == "tee"), None)
            if tee_idx is not None:
                for tok in toks[tee_idx + 1:]:
                    if not tok.startswith("-") and ">" not in tok:
                        targets.append(tok)
        if re.search(r"\b(sed|perl|gawk|awk)\b", seg) and re.search(r"(^|\s)-i\b", seg):
            for tok in reversed(toks):
                if tok.startswith("-") or tok in ("sed", "perl", "gawk", "awk"):
                    continue
                targets.append(tok)
                break
    return targets


def find_rm_removal_targets(cmd):
    """Segments whose literal command word is `rm`/`unlink`: every non-flag
    argument, quote-aware. Wrappers (`xargs rm`, `find -delete`, `sudo rm`,
    `env rm`) are not recognized — documented residual gap, not silently
    claimed as covered."""
    targets = []
    for seg in re.split(r"&&|\|\||[;&\n|]", cmd):
        seg = seg.strip()
        if not seg or not RM_CMD_RE.search(seg):
            continue
        toks = _tokenize(seg)
        if not toks or os.path.basename(toks[0]) not in ("rm", "unlink"):
            continue
        for tok in toks[1:]:
            if not tok.startswith("-"):
                targets.append(tok)
    return targets


def is_sentinel_dir_removal(path):
    """True if `path` names the `.saeed` directory itself (not a file
    beneath it) — removing it takes the sentinel down along with it."""
    norm = path.replace("\\", "/").rstrip("/")
    return os.path.basename(norm) == ".saeed"


def find_sentinel_tamper(cmd):
    """NIT N3: sentinel tampering through Bash, not just Write/Edit. Only
    two deterministic, effectively false-positive-free shapes are covered —
    see the NIT N3 header note for what is intentionally NOT covered."""
    for seg in re.split(r"&&|\|\||[;&\n|]", cmd):
        seg = seg.strip()
        if not seg:
            continue
        for tgt in segment_redirect_targets(seg):
            if is_sentinel_path(tgt):
                return tgt
    for tgt in find_rm_removal_targets(cmd):
        if is_sentinel_path(tgt) or is_sentinel_dir_removal(tgt):
            return tgt
    return None


if tool_name == "Bash":
    cmd = tool_input.get("command") or ""
    if not isinstance(cmd, str) or not cmd.strip():
        sys.exit(0)

    # Detection 3 (sentinel tamper) applies in any mode except `off`, and
    # `off` already exited above — so a hit here always blocks.
    tamper_hit = find_sentinel_tamper(cmd)
    if tamper_hit:
        print(
            f"BLOCKED: `{tamper_hit}` targets the existing `.saeed/TDD` sentinel "
            "(or its `.saeed` parent directory) — removing or redirect-overwriting "
            "it via a shell command is gate-weakening, the same channel this hook "
            "exists to police. Ask the operator to edit the sentinel directly, "
            "outside of tool calls.",
            file=sys.stderr,
        )
        sys.exit(2)

    hit = next((t for t in find_bypass_targets(cmd) if logic_bearing(t)), None)
    if hit:
        msg = (
            f"TDD-MODE ({MODE}): `{hit}` looks like a bypass-channel write "
            "(echo/printf/sed/awk/perl/tee) into logic-bearing source. These "
            "circumvent the Write/Edit hooks so TDD-mode never sees the change — "
            "use Write/Edit/MultiEdit instead (skills/engineering-method/SKILL.md)."
        )
        print(msg, file=sys.stderr)
        if MODE == "enforce":
            sys.exit(2)
    sys.exit(0)

elif tool_name in ("Write", "Edit", "MultiEdit"):
    file_path = tool_input.get("file_path") or ""
    if not isinstance(file_path, str) or not file_path.strip():
        sys.exit(0)

    if is_sentinel_path(file_path):
        try:
            exists = os.path.lexists(file_path)
        except OSError:
            exists = True  # can't inspect it -> fail closed for a sentinel name
        if exists:
            print(
                "BLOCKED: modifying the existing `.saeed/TDD` sentinel (or a "
                "`.saeed/tdd-state*` file) while TDD-mode is active is gate-weakening — "
                "a SAEED untouchable. Ask the operator to edit the sentinel directly, or "
                "park the request under '## Awaiting operator' in .saeed/queue.md.",
                file=sys.stderr,
            )
            sys.exit(2)
        sys.exit(0)  # first-time creation of the sentinel is legitimate

    if not logic_bearing(file_path):
        sys.exit(0)

    has_test = changeset_has_test_file()
    if has_test is False:
        msg = (
            f"TDD-MODE ({MODE}): editing logic-bearing `{os.path.basename(file_path)}` "
            "with no added/modified test file in the pending change-set (git status). "
            "TDD-mode expects tests to lead — add or extend a test alongside this change "
            "(skills/engineering-method/SKILL.md judges the ordering nuance, not this hook)."
        )
        print(msg, file=sys.stderr)
        if MODE == "enforce":
            sys.exit(2)
    sys.exit(0)

else:
    sys.exit(0)
PYEOF
exit $?
