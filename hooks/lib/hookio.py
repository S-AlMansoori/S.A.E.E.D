"""hookio — shared, stdlib-only parsing for SAEED's guard hooks.

Imported by guard-tdd-mode.sh, guard-config-protection.sh and
guard-attribution-canon.sh (each puts hooks/lib on sys.path). One home for:
  - shell write-target extraction (quote-aware via shlex, `cd`-tracking), so
    every guard sees `tee`, `sed -i`, `truncate`, `rm`, `mv`/`cp`, `dd of=`
    and every redirection the same way;
  - the OpenAI Codex `apply_patch` envelope, which Codex uses for every file
    edit (its Write/Edit hook matchers are aliases for it), parsed into
    per-file records so the edit guards never fail open under Codex.
A heuristic layer, not a shell: indirection resolved at run time (eval,
sh -c, variables) is out of scope, as each guard's header states.
"""
import os
import re
import shlex

SEP_CHARS = set(";&|()")
REDIRECTS = {">", ">>", ">|", "&>", "&>>", "1>", "2>", "1>>", "2>>"}
WRAPPERS = {"sudo", "env", "command", "exec", "nohup", "time", "xargs", "nice"}
REMOVERS = {"rm", "unlink", "truncate", "shred"}
COPIERS = {"mv", "cp", "install", "ln", "rsync"}
INPLACE = {"sed", "gsed", "perl", "awk", "gawk"}
BYPASS_CMDS = {"echo", "printf", "sed", "gsed", "awk", "gawk", "perl", "tee", "cat"}


def _lex(text):
    lex = shlex.shlex(text, posix=True, punctuation_chars=";&|()<>")
    lex.whitespace_split = True
    return list(lex)


def segments(cmd):
    """Command segments as lists of shell words. Unparseable lines (an
    apostrophe in a heredoc body, say) degrade to a naive split for that line
    only instead of discarding the whole check."""
    try:
        toks = _lex(cmd.replace("\n", " ; "))
    except ValueError:
        toks = []
        for line in cmd.split("\n"):
            try:
                toks.extend(_lex(line))
            except ValueError:
                toks.extend(t.strip("'\"") for t in line.split())
            toks.append(";")
    out, cur = [], []
    for t in toks:
        if t and all(c in SEP_CHARS for c in t):
            if cur:
                out.append(cur)
            cur = []
        else:
            cur.append(t)
    if cur:
        out.append(cur)
    return out


def redirect_targets(seg):
    tgts = []
    for i, t in enumerate(seg):
        if t in REDIRECTS and i + 1 < len(seg):
            tgts.append(seg[i + 1])
    return tgts


def command_word(seg):
    i = 0
    while i < len(seg) and (seg[i] in WRAPPERS or re.match(r"^[A-Za-z_][A-Za-z0-9_]*=", seg[i])
                            or (i > 0 and seg[i - 1] in WRAPPERS and seg[i].startswith("-"))):
        i += 1
    if i >= len(seg):
        return None, []
    return os.path.basename(seg[i]), seg[i + 1:]


VALUE_FLAGS = {
    "truncate": {"-s", "--size", "-r", "--reference"},
    "sed": {"-e", "-f", "--expression", "--file"},
    "gsed": {"-e", "-f", "--expression", "--file"},
    "perl": {"-e", "-E", "-M", "-I"},
    "awk": {"-f", "-v", "-F"},
    "gawk": {"-f", "-v", "-F"},
    "tee": set(),
}


def operands(args, value_flags=()):
    """Non-flag words before any redirection (`truncate -s 0 f` -> [f])."""
    out, skip = [], False
    for a in args:
        if skip:
            skip = False
            continue
        if a in REDIRECTS or a.startswith("<") or a.startswith(">"):
            break
        if a in value_flags:
            skip = True
            continue
        if a.startswith("-"):
            continue
        out.append(a)
    return out


def write_targets(cmd):
    """(path, kind) for every file a shell command appears to write, remove
    or overwrite: any redirection, tee args, in-place-edit targets, removers,
    and copy/move operands. `cd` inside the command is tracked so
    `cd .saeed && rm TDD` resolves to `.saeed/TDD`."""
    vdir = ""
    found = []
    for seg in segments(cmd):
        word, args = command_word(seg)
        if word == "cd":
            ops = operands(args)
            vdir = os.path.join(vdir, ops[0]) if ops else ""
            continue

        def add(pth, kind):
            found.append((os.path.join(vdir, pth) if vdir else pth, kind))

        for t in redirect_targets(seg):
            add(t, "redirect")
        if word == "tee":
            for t in operands(args, VALUE_FLAGS["tee"]):
                add(t, "tee")
        elif word in INPLACE and any(a == "-i" or a.startswith("-i") or a.startswith("--in-place") for a in args):
            for t in operands(args, VALUE_FLAGS.get(word, ())):
                add(t, "inplace")
        elif word in REMOVERS:
            for t in operands(args, VALUE_FLAGS.get(word, ())):
                add(t, "remove")
        elif word in COPIERS:
            # Only the destination is written; `mv` also removes its sources,
            # while `cp`/`install`/`ln`/`rsync` merely read theirs.
            ops = operands(args)
            if len(ops) >= 2:
                for t in ops[:-1]:
                    if word == "mv":
                        add(t, "remove")
                add(ops[-1], "copy")
        elif word == "dd":
            for a in args:
                if a.startswith("of="):
                    add(a[3:], "redirect")
        elif word == "find" and "-delete" in args:
            for t in operands(args):
                add(t, "remove")
    return found


def parse_apply_patch(text):
    """Codex `apply_patch` envelope -> [(path, op, added_text)], op one of
    add / update / delete; a `*** Move to:` destination is reported as add."""
    recs = []
    cur = None
    for line in text.splitlines():
        m = re.match(r"^\*\*\* (Add|Update|Delete) File: (.+?)\s*$", line)
        if m:
            cur = [m.group(2), m.group(1).lower(), []]
            recs.append(cur)
            continue
        m = re.match(r"^\*\*\* Move to: (.+?)\s*$", line)
        if m:
            cur = [m.group(1), "add", []]
            recs.append(cur)
            continue
        if cur is not None and line.startswith("+"):
            cur[2].append(line[1:])
    return [(pth, op, "\n".join(added)) for pth, op, added in recs]


def patch_text(tool_input):
    """The patch body from a Codex apply_patch tool_input, or ''."""
    text = tool_input.get("command") or tool_input.get("input") or tool_input.get("patch") or ""
    if isinstance(text, list):
        text = "\n".join(str(t) for t in text)
    return text if isinstance(text, str) else ""
