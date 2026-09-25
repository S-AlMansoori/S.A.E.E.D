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
# HOW IT MATCHES: the command is tokenized with shlex the way the shell will
# see it, so a commit message that *mentions* --no-verify is one word (not a
# false positive) while --"no-verify" unquotes to the real flag. Flags are
# matched as whole tokens, including git's accepted abbreviations (--no-verif),
# commit's -n inside short-option clusters (-en), and hooksPath overrides via
# -c, --config-env, git config, GIT_CONFIG_KEY_n / GIT_CONFIG_PARAMETERS, and
# HUSKY=0.
#
# KNOWN LIMITS (accepted): indirection the shell resolves at run time
# (eval, sh -c "...", variables holding flags, aliases) is not expanded —
# this is a guardrail against habit, not a sandbox.

PY="$(command -v python3 || true)"
if [[ -z "${PY}" ]]; then
  echo "SAEED guard-git-bypass: python3 not found; guard inactive (fail-open)." >&2
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
import shlex
import sys

try:
    with open(sys.argv[1], encoding="utf-8") as f:
        data = json.load(f)
except Exception:
    sys.exit(0)

cmd = (data.get("tool_input") or {}).get("command") or ""
if not isinstance(cmd, str) or not cmd.strip():
    sys.exit(0)


def block(reason: str) -> None:
    print(reason, file=sys.stderr)
    sys.exit(2)


NO_VERIFY_MSG = (
    "BLOCKED: `--no-verify` with `git {sub}` is not allowed. SAEED never "
    "bypasses its own gates (skills/self-governance/SKILL.md — the untouchables). "
    "Run the hooks and fix what they catch; if a hook itself is broken, fix the "
    "hook or park the problem under '## Awaiting operator' in .saeed/queue.md."
)
DASH_N_MSG = (
    "BLOCKED: `git commit -n` (no-verify) is not allowed — same rule as "
    "`--no-verify`: SAEED never bypasses its own gates. Run the hooks and fix "
    "what they catch instead."
)
CLI_HOOKSPATH_MSG = (
    "BLOCKED: overriding `core.hooksPath` on the command line disables the repo's "
    "git hooks — SAEED never weakens its own gates. Run the real hooks."
)
CONFIG_HOOKSPATH_MSG = (
    "BLOCKED: setting `core.hooksPath` via git config disables the repo's git "
    "hooks — SAEED never weakens its own gates. If a hook is genuinely broken, "
    "fix it or park the change for the operator."
)
ENV_MSG = (
    "BLOCKED: disabling git hooks through the environment ({what}) is the same "
    "bypass as `--no-verify` — SAEED never weakens its own gates. Run the real hooks."
)

GATED = {"commit", "push", "merge", "rebase", "cherry-pick", "am"}
# Long option git accepts as an unambiguous prefix of --no-verify on every
# gated subcommand (`--no-` alone is ambiguous there and git rejects it).
NV_MIN = len("--no-v")
# git commit short options that consume a value: required (next token when not
# glued) and optional (glued only).
COMMIT_ARG_REQ = set("mFCct")
COMMIT_ARG_OPT = set("Su")
GIT_GLOBAL_ARG = {"-c", "-C", "--git-dir", "--work-tree", "--namespace",
                  "--exec-path", "--super-prefix", "--config-env"}
ENV_ASSIGN = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*=")
HOOKSPATH = "core.hookspath"


def is_no_verify(tok: str) -> bool:
    name = tok.split("=", 1)[0]
    return len(name) >= NV_MIN and "--no-verify".startswith(name)


def check_commit_short(tok: str) -> tuple:
    """Walk a short-option cluster like -anm'msg'. Returns (has_n, consumes_next)."""
    body = tok[1:]
    for i, ch in enumerate(body):
        if ch == "n":
            return True, False
        if ch in COMMIT_ARG_REQ:
            return False, i == len(body) - 1
        if ch in COMMIT_ARG_OPT:
            return False, False
    return False, False


def check_segment(seg: list) -> None:
    env = {}
    i = 0
    # Leading VAR=val assignments, optionally behind `env` / `command`.
    while i < len(seg):
        t = seg[i]
        if ENV_ASSIGN.match(t):
            k, v = t.split("=", 1)
            env[k] = v
            i += 1
        elif t in ("env", "command", "exec", "nohup", "time") or (t.startswith("-") and i > 0 and seg[i - 1] == "env"):
            i += 1
        else:
            break
    if i >= len(seg) or seg[i].rsplit("/", 1)[-1] != "git":
        return
    i += 1

    for k, v in env.items():
        if re.fullmatch(r"GIT_CONFIG_KEY_\d+", k) and v.lower() == HOOKSPATH:
            block(ENV_MSG.format(what=k + "=core.hooksPath"))
        if k == "GIT_CONFIG_PARAMETERS" and HOOKSPATH in v.lower():
            block(ENV_MSG.format(what="GIT_CONFIG_PARAMETERS"))

    # Global options before the subcommand.
    while i < len(seg) and seg[i].startswith("-"):
        t = seg[i]
        name = t.split("=", 1)[0]
        val = None
        if name in ("-c", "--config-env"):
            if "=" in t and name == "--config-env":
                val = t.split("=", 1)[1]
            elif i + 1 < len(seg):
                val = seg[i + 1]
                i += 1
        elif t.startswith("-c") and len(t) > 2:
            val = t[2:]
        elif name in GIT_GLOBAL_ARG and "=" not in t and i + 1 < len(seg):
            i += 1
        elif t.startswith("-C") and len(t) > 2:
            pass
        if val is not None and val.split("=", 1)[0].strip().lower() == HOOKSPATH:
            block(CLI_HOOKSPATH_MSG)
        i += 1
    if i >= len(seg):
        return
    sub = seg[i]
    args = seg[i + 1:]

    if sub in GATED and env.get("HUSKY") == "0":
        block(ENV_MSG.format(what="HUSKY=0"))

    if sub == "config":
        low = [a.lower() for a in args]
        if HOOKSPATH in low:
            reading = {"--get", "--get-all", "--get-regexp", "--unset", "--unset-all",
                       "--list", "-l", "get", "unset", "list"}
            if not reading.intersection(low):
                block(CONFIG_HOOKSPATH_MSG)
        return

    if sub not in GATED:
        return
    skip = False
    for a in args:
        if skip:
            skip = False
            continue
        if a == "--":
            break
        if a.startswith("--"):
            if is_no_verify(a):
                block(NO_VERIFY_MSG.format(sub=sub))
            # --message/--file/--reuse-message etc. without '=' take the next token.
            if sub == "commit" and "=" not in a and a in (
                    "--message", "--file", "--reuse-message", "--reedit-message",
                    "--fixup", "--squash", "--author", "--date", "--template",
                    "--cleanup", "--trailer", "--pathspec-from-file"):
                skip = True
        elif sub == "commit" and a.startswith("-") and len(a) > 1:
            has_n, skip = check_commit_short(a)
            if has_n:
                block(DASH_N_MSG)


def tokenize(command: str):
    """Split into command segments of shell words, honouring quotes the way the
    shell will (so --"no-verify" is --no-verify and "don't" stays one word)."""
    lex = shlex.shlex(command.replace("\n", " ; "), posix=True, punctuation_chars=";&|()<>")
    lex.whitespace_split = True
    segs, cur = [], []
    for tok in lex:
        if tok and all(c in ";&|()" for c in tok):
            if cur:
                segs.append(cur)
            cur = []
        else:
            cur.append(tok)
    if cur:
        segs.append(cur)
    return segs


def strip_quoted(s: str) -> str:
    """Fallback for input shlex cannot parse (unbalanced quotes): blank out
    quoted spans, double-quoted first so an apostrophe inside one survives."""
    s = re.sub(r'"(?:[^"\\]|\\.)*"', " ", s)
    s = re.sub(r"'[^']*'", " ", s)
    return s


try:
    segments = tokenize(cmd)
except ValueError:
    segments = tokenize(strip_quoted(cmd).replace("'", " ").replace('"', " "))

for seg in segments:
    check_segment(seg)

sys.exit(0)
PYEOF
exit $?
