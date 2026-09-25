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

# Fast path: no sentinel in this directory or any parent -> silent, zero
# overhead (python3 is never invoked). Walking up means a session whose cwd
# is a subdirectory of an opted-in repo is still covered.
_dir="${PWD}"
_found=""
while [[ -n "${_dir}" ]]; do
  if [[ -f "${_dir}/.saeed/TDD" ]]; then
    _found=1
    break
  fi
  [[ "${_dir}" == "/" ]] && break
  _dir="$(dirname -- "${_dir}")"
done
if [[ -z "${_found}" ]]; then
  exit 0
fi

PY="$(command -v python3 || true)"
if [[ -z "${PY}" ]]; then
  echo "SAEED guard-tdd-mode: python3 not found; guard inactive (fail-open)." >&2
  exit 0
fi

# The heredoc below occupies stdin for the python program itself, so the hook
# payload is captured to a temp file first and passed by path (argv), exactly
# like the other guard hooks in this directory.
PAYLOAD="$(mktemp)"
trap 'rm -f "${PAYLOAD}"' EXIT
cat > "${PAYLOAD}" 2>/dev/null || true

"${PY}" - "${PAYLOAD}" "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/lib" <<'PYEOF'
import fnmatch
import json
import os
import re
import subprocess
import sys

sys.path.insert(0, sys.argv[2] if len(sys.argv) > 2 else "")
try:
    from hookio import parse_apply_patch, patch_text, write_targets
except ImportError:
    print("SAEED guard-tdd-mode: hooks/lib/hookio.py missing — guard inactive.", file=sys.stderr)
    sys.exit(0)


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


def find_sentinel(start):
    """Walk up from `start` to the first directory holding `.saeed/TDD`;
    returns (repo_dir, sentinel_path) or (None, None)."""
    d = os.path.abspath(start or ".")
    while True:
        cand = os.path.join(d, ".saeed", "TDD")
        if os.path.isfile(cand):
            return d, cand
        parent = os.path.dirname(d)
        if parent == d:
            return None, None
        d = parent


try:
    with open(sys.argv[1], encoding="utf-8") as f:
        data = json.load(f)
except Exception:
    sys.exit(0)

tool_name = data.get("tool_name") or ""
tool_input = data.get("tool_input") or {}
CWD = data.get("cwd") if isinstance(data.get("cwd"), str) and data.get("cwd") else os.getcwd()

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
    """`.saeed/TDD` or `.saeed/tdd-state*`, after normalization (so
    `.saeed//TDD` and `.saeed/./TDD` count), case-insensitively (APFS and
    NTFS resolve `.SAEED/tdd` to the same file), and glob-aware (`TD?`)."""
    norm = os.path.normpath(path.replace("\\", "/")).replace("\\", "/")
    parts = norm.split("/")
    if len(parts) < 2:
        return False
    parent, name = parts[-2].lower(), parts[-1].lower()
    if not fnmatch.fnmatchcase(".saeed", parent):
        return False
    return (fnmatch.fnmatchcase("tdd", name) or name.startswith("tdd-state")
            or fnmatch.fnmatchcase("tdd-state", name))


def is_sentinel_dir_removal(path):
    """True if `path` names the `.saeed` directory itself (not a file
    beneath it) — removing it takes the sentinel down along with it."""
    norm = os.path.normpath(path.replace("\\", "/")).replace("\\", "/")
    return fnmatch.fnmatchcase(".saeed", os.path.basename(norm).lower())


def changeset_has_test_file(repo_dir):
    """Deterministic proxy: is any test file part of the pending change-set
    (working tree, per `git status`) in the target's repo? Returns True /
    False, or None when indeterminate (not a git repo) — indeterminate is
    never treated as a violation. NUL-delimited porcelain, so a path with
    spaces is not quoted and misread."""
    try:
        root = subprocess.run(
            ["git", "-C", repo_dir, "rev-parse", "--show-toplevel"],
            capture_output=True, text=True, timeout=5,
        )
        if root.returncode != 0:
            return None
        top = root.stdout.strip()
        status = subprocess.run(
            ["git", "status", "--porcelain", "-z", "--untracked-files=all"],
            capture_output=True, text=True, timeout=5, cwd=top,
        )
        if status.returncode != 0:
            return None
        entries = status.stdout.split("\0")
        i = 0
        while i < len(entries):
            entry = entries[i]
            i += 1
            if len(entry) < 4:
                continue
            xy, entry_path = entry[:2], entry[3:]
            if "R" in xy or "C" in xy:
                i += 1  # the rename/copy source follows as its own NUL field
            if is_test_path(entry_path):
                return True
        return False
    except Exception:
        return None


def block_tamper(what):
    print(
        f"BLOCKED: `{what}` targets the existing `.saeed/TDD` sentinel "
        "(or a `.saeed/tdd-state*` file, or the `.saeed` directory itself) — "
        "modifying, removing or overwriting it from a tool call is gate-weakening, "
        "a SAEED untouchable. Ask the operator to edit the sentinel directly, "
        "outside of tool calls, or park the request under '## Awaiting operator' "
        "in .saeed/queue.md.",
        file=sys.stderr,
    )
    sys.exit(2)


def verdict(msg, mode):
    print(msg, file=sys.stderr)
    if mode == "enforce":
        sys.exit(2)


def mode_for(start):
    repo, sentinel = find_sentinel(start)
    if not sentinel:
        return None, None
    m = read_sentinel(sentinel)
    # Garbage/unknown content fails open the same way (never brick on a typo).
    return (m if m in ("advisory", "enforce") else None), repo


def check_file_write(file_path, exists_hint=None, extra_tests=()):
    """Shared Write/Edit/apply_patch branch for one target file."""
    abs_path = file_path if os.path.isabs(file_path) else os.path.join(CWD, file_path)
    mode, repo = mode_for(os.path.dirname(abs_path))
    if not mode:
        return
    if is_sentinel_path(abs_path):
        exists = exists_hint
        if exists is None:
            try:
                exists = os.path.lexists(abs_path)
            except OSError:
                exists = True  # can't inspect it -> fail closed for a sentinel name
        if exists:
            block_tamper(file_path)
        return  # first-time creation of the sentinel is legitimate
    if not logic_bearing(abs_path):
        return
    if any(is_test_path(t) for t in extra_tests):
        return
    if changeset_has_test_file(repo) is False:
        verdict(
            f"TDD-MODE ({mode}): editing logic-bearing `{os.path.basename(file_path)}` "
            "with no added/modified test file in the pending change-set (git status). "
            "TDD-mode expects tests to lead — add or extend a test alongside this change "
            "(skills/engineering-method/SKILL.md judges the ordering nuance, not this hook).",
            mode,
        )


if tool_name == "Bash":
    cmd = tool_input.get("command") or ""
    if not isinstance(cmd, str) or not cmd.strip():
        sys.exit(0)
    mode, repo = mode_for(CWD)
    if not mode:
        sys.exit(0)
    targets = write_targets(cmd)
    # Detection 3 (sentinel tamper) blocks in any active mode.
    for tgt, kind in targets:
        if is_sentinel_path(tgt) or (kind == "remove" and is_sentinel_dir_removal(tgt)):
            block_tamper(tgt)
    # Detection 1: shell write channels into logic-bearing source.
    for tgt, kind in targets:
        if kind in ("redirect", "tee", "inplace") and logic_bearing(tgt):
            verdict(
                f"TDD-MODE ({mode}): `{tgt}` looks like a bypass-channel write "
                "(redirection, tee, or an in-place sed/awk/perl edit) into logic-bearing "
                "source. These circumvent the Write/Edit hooks so TDD-mode never sees the "
                "change — use the editor tools instead (skills/engineering-method/SKILL.md).",
                mode,
            )
            break
    sys.exit(0)

elif tool_name in ("Write", "Edit", "MultiEdit"):
    file_path = tool_input.get("file_path") or ""
    if not isinstance(file_path, str) or not file_path.strip():
        sys.exit(0)
    check_file_write(file_path)
    sys.exit(0)

elif tool_name == "apply_patch":
    # OpenAI Codex routes every file edit through apply_patch; its Write/Edit
    # matchers are aliases for it and the patch text arrives as a command.
    text = patch_text(tool_input)
    if not text.strip():
        sys.exit(0)
    recs = parse_apply_patch(text)
    tests = [pth for pth, op, _ in recs if op != "delete"]
    for pth, op, _ in recs:
        check_file_write(pth, exists_hint=True if op in ("update", "delete") else None,
                         extra_tests=tests)
    sys.exit(0)

else:
    sys.exit(0)
PYEOF
exit $?
