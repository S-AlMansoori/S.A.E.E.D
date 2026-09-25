#!/usr/bin/env bash
#
# gen-codex.sh — generate SAEED's OpenAI Codex compatibility layer.
#
# WHY THIS EXISTS
#   Codex reads the same SKILL.md format Claude Code does, but it has no
#   `agents/*.md` subagents and no `/plugin:command` slash commands — its
#   custom agents are TOML files and its reusable prompts are skills. Hand-
#   maintaining a second copy of 55 agents and 7 commands would drift on the
#   first edit, so the Codex tree is GENERATED from the Claude sources and a
#   `--check` mode lets validate-fleet.sh / CI fail on drift.
#
# WHAT IT GENERATES (deterministic: sorted, no timestamps)
#   codex/agents/<name>.toml        one Codex custom agent per agents/<name>.md
#                                   (name, description, developer_instructions;
#                                   model tier -> model_reasoning_effort;
#                                   no Write/Edit/Bash -> sandbox_mode read-only)
#   codex/skills/<canon>            relative symlink -> ../../skills/<canon>
#   codex/skills/saeed-<cmd>/       one skill per commands/<cmd>.md, invoked as
#                                   `$saeed-<cmd>`, plus agents/openai.yaml that
#                                   disables implicit invocation
#   .codex-plugin/plugin.json       Codex plugin manifest; `version` is copied
#                                   from .claude-plugin/plugin.json so the two
#                                   can never disagree
#
# Usage:
#   scripts/gen-codex.sh                     regenerate the tree in place
#   scripts/gen-codex.sh --check             exit 1 if the committed tree drifted
#   scripts/gen-codex.sh --install --user    symlink codex/agents/*.toml into ~/.codex/agents/
#   scripts/gen-codex.sh --install <dir>     symlink them into <dir>/.codex/agents/
#
# Re-run after editing agents/, commands/, skills/ or the Claude manifest version.
# Pure bash (3.2-compatible) + python3 stdlib — no installs, no network.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MODE="generate"
INSTALL_DEST=""

case "${1:-}" in
  "") ;;
  --check) MODE="check" ;;
  --install)
    MODE="install"
    case "${2:-}" in
      --user) INSTALL_DEST="${HOME}/.codex/agents" ;;
      "") echo "gen-codex: --install needs --user or a target project directory" >&2; exit 2 ;;
      *)
        if [ ! -d "$2" ]; then echo "gen-codex: not a directory: $2" >&2; exit 2; fi
        INSTALL_DEST="$(cd "$2" && pwd)/.codex/agents"
        ;;
    esac
    ;;
  -h|--help) sed -n '2,33p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
  *) echo "gen-codex: unknown option: $1 (try --help)" >&2; exit 2 ;;
esac

command -v python3 >/dev/null 2>&1 || { echo "gen-codex: python3 is required" >&2; exit 2; }

# ---------------------------------------------------------------- install ---
if [ "$MODE" = "install" ]; then
  if [ ! -d "$ROOT/codex/agents" ]; then
    echo "gen-codex: $ROOT/codex/agents missing — run scripts/gen-codex.sh first" >&2; exit 1
  fi
  mkdir -p "$INSTALL_DEST"
  linked=0; kept=0; skipped=0
  for src in "$ROOT"/codex/agents/*.toml; do
    dest="$INSTALL_DEST/$(basename "$src")"
    if [ -L "$dest" ]; then
      if [ "$(readlink "$dest")" = "$src" ]; then kept=$((kept+1)); continue; fi
      rm "$dest"   # stale symlink (e.g. repo moved) — ours to replace
    elif [ -e "$dest" ]; then
      echo "gen-codex: SKIP $dest exists and is not a symlink — left untouched" >&2
      skipped=$((skipped+1)); continue
    fi
    ln -s "$src" "$dest"
    linked=$((linked+1))
  done
  echo "gen-codex: $INSTALL_DEST — linked $linked, already current $kept, skipped $skipped (non-symlink)."
  [ "$skipped" -eq 0 ] || exit 1
  exit 0
fi

# -------------------------------------------------------------- generator ---
generate() {  # $1 = output root
  python3 - "$ROOT" "$1" <<'PY'
import json, os, re, sys

root, out = sys.argv[1], sys.argv[2]

def read(p):
    with open(p, encoding="utf-8") as f:
        return f.read()

def write(p, text):
    os.makedirs(os.path.dirname(p), exist_ok=True)
    with open(p, "w", encoding="utf-8", newline="\n") as f:
        f.write(text)

def split_frontmatter(path):
    text = read(path)
    m = re.match(r"^---\n(.*?)\n---\n?(.*)\Z", text, re.S)
    if not m:
        sys.exit("gen-codex: no YAML frontmatter in %s" % path)
    meta = {}
    for line in m.group(1).splitlines():
        km = re.match(r"^([A-Za-z0-9_-]+):\s*(.*)$", line)
        if not km:
            continue
        val = km.group(2).strip()
        if len(val) >= 2 and val[0] == val[-1] == '"':
            val = json.loads(val)          # double-quoted: JSON-compatible escapes
        elif len(val) >= 2 and val[0] == val[-1] == "'":
            val = val[1:-1].replace("''", "'")
        meta[km.group(1)] = val
    return meta, m.group(2).strip("\n") + "\n"

def toml_basic(s):
    o = []
    for ch in s:
        c = ord(ch)
        if ch == "\\": o.append("\\\\")
        elif ch == '"': o.append('\\"')
        elif ch == "\n": o.append("\\n")
        elif ch == "\t": o.append("\\t")
        elif c < 0x20 or c == 0x7f: o.append("\\u%04x" % c)
        else: o.append(ch)
    return '"' + "".join(o) + '"'

def toml_multiline(s):
    bad = "'''" in s or s.endswith("'") or any(
        (ord(c) < 0x20 and c not in "\n\t") or ord(c) == 0x7f for c in s)
    if bad:
        return toml_basic(s)
    return "'''\n" + s + "'''"

# ---- agents -> codex/agents/*.toml
EFFORT = {"fable": "high", "opus": "high", "sonnet": "medium"}
agents_dir = os.path.join(root, "agents")
n_agents = 0
for fn in sorted(os.listdir(agents_dir)):
    if not fn.endswith(".md"):
        continue
    name = fn[:-3]
    meta, body = split_frontmatter(os.path.join(agents_dir, fn))
    if meta.get("name") != name:
        sys.exit("gen-codex: agents/%s name %r != filename" % (fn, meta.get("name")))
    tools = {t.strip() for t in meta.get("tools", "").split(",") if t.strip()}
    lines = [
        "# GENERATED by scripts/gen-codex.sh from agents/%s — do not edit" % fn,
        "name = " + toml_basic(name),
        "description = " + toml_basic(meta.get("description", "")),
    ]
    effort = EFFORT.get(meta.get("model", ""))
    if effort:
        lines.append("model_reasoning_effort = " + toml_basic(effort))
    if tools and not (tools & {"Write", "Edit", "Bash"}):
        lines.append('sandbox_mode = "read-only"')
    lines.append("developer_instructions = " + toml_multiline(body))
    write(os.path.join(out, "codex", "agents", name + ".toml"), "\n".join(lines) + "\n")
    n_agents += 1

# ---- canons -> codex/skills/<canon> symlinks
skills_dir = os.path.join(root, "skills")
n_canons = 0
for sk in sorted(os.listdir(skills_dir)):
    if not os.path.isfile(os.path.join(skills_dir, sk, "SKILL.md")):
        continue
    link = os.path.join(out, "codex", "skills", sk)
    os.makedirs(os.path.dirname(link), exist_ok=True)
    os.symlink(os.path.join("..", "..", "skills", sk), link)
    n_canons += 1

# ---- commands -> codex/skills/saeed-<cmd>/
cmd_dir = os.path.join(root, "commands")
n_cmds = 0
for fn in sorted(os.listdir(cmd_dir)):
    if not fn.endswith(".md"):
        continue
    cmd = fn[:-3]
    meta, body = split_frontmatter(os.path.join(cmd_dir, fn))
    skill = "saeed-" + cmd
    hint = meta.get("argument-hint", "")
    pre = [
        "> **Codex mapping** (generated from `commands/%s`). In Codex, `/saeed:%s` is `$%s`;"
        " every `/saeed:<x>` below means `$saeed-<x>`." % (fn, cmd, skill),
        "> A \"`<agent>` subagent\" (or an agent named in backticks) means the Codex custom agent of"
        " the same name from `codex/agents/` — install them with `scripts/gen-codex.sh --install`"
        " (see `docs/CODEX.md`); if one is not installed, do that role's work yourself under its rules.",
        "> `$ARGUMENTS` = the text the user wrote after `$%s`%s; `skills/<canon>/SKILL.md` paths"
        " refer to the SAEED plugin's bundled canons (also available as `$<canon>`)." % (
            skill, (" (" + hint + ")") if hint else ""),
    ]
    text = (
        "---\n"
        "name: %s\n"
        "description: %s\n"
        "---\n\n"
        "<!-- GENERATED by scripts/gen-codex.sh from commands/%s — do not edit -->\n\n"
        "%s\n\n%s"
    ) % (skill, json.dumps(meta.get("description", ""), ensure_ascii=False), fn,
         "\n".join(pre), body)
    write(os.path.join(out, "codex", "skills", skill, "SKILL.md"), text)
    write(os.path.join(out, "codex", "skills", skill, "agents", "openai.yaml"),
          "# GENERATED by scripts/gen-codex.sh — do not edit\n"
          "policy:\n  allow_implicit_invocation: false\n")
    n_cmds += 1

# ---- Codex plugin manifest (version mirrors the Claude manifest)
cm = json.loads(read(os.path.join(root, ".claude-plugin", "plugin.json")))
manifest = {
    "name": "saeed",
    "version": cm["version"],
    "description": ("SAEED (سعيد) — Self-Advancing Elite Engineering Directorate: %d engineering"
                    " canons as skills, the /saeed:* commands as $saeed-* skills, guardrail hooks,"
                    " and %d specialist agents installable as Codex custom agents. Bilingual"
                    " Arabic/English. A product of NABAD Computer Solutions L.L.C."
                    % (n_canons, n_agents)),
    "author": cm["author"],
    "homepage": cm["repository"],
    "repository": cm["repository"],
    "license": cm["license"],
    "keywords": ["subagents", "multi-agent", "verification", "security", "guardrails",
                 "bilingual", "arabic", "self-improving"],
    "skills": "./codex/skills/",
    "hooks": "./hooks/hooks.json",
    "interface": {"displayName": "SAEED", "category": "Coding"},
}
write(os.path.join(out, ".codex-plugin", "plugin.json"),
      json.dumps(manifest, ensure_ascii=False, indent=2) + "\n")

sys.stderr.write("gen-codex: %d agents, %d canon links, %d command skills, manifest v%s\n"
                 % (n_agents, n_canons, n_cmds, cm["version"]))
PY
}

compare() {  # $1 = expected root, $2 = actual root; prints drift, exit 1 on any
  python3 - "$1" "$2" <<'PY'
import os, sys
exp, act = sys.argv[1], sys.argv[2]

def snapshot(base):
    snap = {}
    paths = [os.path.join(base, ".codex-plugin", "plugin.json")]
    for dp, dns, fns in os.walk(os.path.join(base, "codex")):  # os.walk does not follow symlinks
        for n in dns + fns:
            paths.append(os.path.join(dp, n))
    for p in paths:
        rel = os.path.relpath(p, base)
        if os.path.islink(p):
            snap[rel] = ("link", os.readlink(p))
        elif os.path.isfile(p):
            with open(p, "rb") as f:
                snap[rel] = ("file", f.read())
        elif os.path.isdir(p):
            snap[rel] = ("dir", None)
    return snap

e, a = snapshot(exp), snapshot(act)
drift = []
for rel in sorted(set(e) | set(a)):
    if rel not in a:
        drift.append("missing:  " + rel)
    elif rel not in e:
        drift.append("stale:    " + rel)
    elif e[rel] != a[rel]:
        kind = e[rel][0] if e[rel][0] == a[rel][0] else "%s->%s" % (a[rel][0], e[rel][0])
        drift.append("differs:  %s (%s)" % (rel, kind))
if drift:
    print("gen-codex --check: FAIL — the Codex layer is out of date with agents/, commands/,")
    print("skills/ or .claude-plugin/plugin.json (%d paths). Run scripts/gen-codex.sh and commit:" % len(drift))
    for d in drift[:40]:
        print("  " + d)
    if len(drift) > 40:
        print("  ... and %d more" % (len(drift) - 40))
    sys.exit(1)
print("gen-codex --check: OK — codex/ and .codex-plugin/plugin.json match their sources.")
PY
}

if [ "$MODE" = "check" ]; then
  TMP="$(mktemp -d "${TMPDIR:-/tmp}/gen-codex.XXXXXX")"
  trap 'rm -rf "$TMP"' EXIT
  generate "$TMP" 2>/dev/null
  compare "$TMP" "$ROOT"
  exit $?
fi

# ---------------------------------------------------------------- generate ---
TMP="$(mktemp -d "${TMPDIR:-/tmp}/gen-codex.XXXXXX")"
trap 'rm -rf "$TMP"' EXIT
generate "$TMP"                     # build fully first; only swap in on success
rm -rf "$ROOT/codex"
mv "$TMP/codex" "$ROOT/codex"
mkdir -p "$ROOT/.codex-plugin"
mv "$TMP/.codex-plugin/plugin.json" "$ROOT/.codex-plugin/plugin.json"
echo "gen-codex: wrote $ROOT/codex/ and $ROOT/.codex-plugin/plugin.json"
