#!/usr/bin/env bash
#
# validate-fleet.sh — SU-19 executable self-lint gate for the SAEED plugin repo.
#
# WHY THIS EXISTS
#   Two SAEED self-upgrade cycles shipped stale bookkeeping that survived that
#   cycle's own (prose-based) verification: a stale Arabic agent count in
#   cycle 1, and a stale `.saeed/state.json` roster_agents count in cycle 3.
#   This script turns "someone re-read the docs and it looked right" into a
#   deterministic, executable gate so that class of defect cannot recur
#   silently. Run it after ANY change to the roster (agents/*.md added or
#   removed) or to the manifests/docs that restate the agent count.
#
# WHAT IT CHECKS (see README below for detail on each)
#   1. Count drift    — every surface that states "N agents" agrees with the
#                        actual number of agents/*.md files (English + Arabic).
#   2. Frontmatter     — every agents/*.md has name/description/model in YAML
#                        frontmatter, and name == filename (minus .md).
#   3. Model tally     — opus/sonnet counts across agents/*.md match the
#                        tallies documented in .saeed/models.md AND the
#                        docs/what-is-saeed.html "Model mix" legend rows.
#   4. JSON validity   — plugin.json, marketplace.json, hooks.json,
#                        .saeed/state.json all parse as JSON.
#   5. Handoff refs    — every backtick agent-name reference inside a
#                        `## Handoffs` section resolves to a real agent file.
#   6. Stack drift      (warning only) — flags if per-agent "Stack context"
#                        paragraphs have diverged (more than one distinct
#                        whitespace-normalized hash among the ones present).
#   7. Governance       — the mechanical FLOOR under the "park, never deadlock"
#                        keystone: .saeed/AUTONOMY (if present) names a known
#                        level, and .saeed/queue.md (if present) carries the
#                        standing "## Awaiting operator" parking anchor. The
#                        semantic question (was the RIGHT thing parked?) is a
#                        judgment call, enforced by self-eval-critic, not here.
#   8. Hook contract     — every ${CLAUDE_PLUGIN_ROOT} script referenced by
#                        hooks/hooks.json exists, and the guardrail hooks are
#                        smoke-tested with real payloads: bypass attempts must
#                        exit 2 (block), benign ones 0, and the session brief
#                        must emit valid SessionStart JSON. (SU-20, absorbed
#                        from ECC's tested-hooks practice.)
#   9. Frontmatter (cmd/skill) — every commands/*.md has a description; every
#                        skills/*/SKILL.md has name (matching its directory)
#                        and a single-line description. (Absorbed from ECC's
#                        validate-commands / validate-skills CI gates.)
#
# NOTE on .saeed/: it is per-project runtime state and gitignored, so a fresh
# clone (and CI) has none. Checks that read .saeed/state.json or models.md are
# therefore conditional on the file existing — present-but-stale still fails.
#
# USAGE
#   ./scripts/validate-fleet.sh        # run from anywhere; paths are
#                                       # resolved relative to this script.
#
# EXIT STATUS
#   0  — all hard checks (1-5, 7) passed. Check 6 is advisory and never fails
#        the build; it only prints a warning.
#   1  — one or more hard checks failed. Every violation is printed with the
#        file and expected-vs-found detail before the FAIL summary line.
#
# REQUIREMENTS
#   bash + python3 (standard library only — no pip installs, no network).

set -uo pipefail

# ---------------------------------------------------------------------------
# Resolve repo root relative to this script's own location, so the script
# works no matter what directory it's invoked from.
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." >/dev/null 2>&1 && pwd -P)"

PY="$(command -v python3 || true)"
if [[ -z "${PY}" ]]; then
  echo "FAIL: python3 not found on PATH — required by validate-fleet.sh" >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# All the actual logic lives in an embedded python3 script for robust JSON /
# YAML-frontmatter / regex handling. It exits 0 on pass, 1 on any hard
# failure, and prints a structured PASS/FAIL report (plus warnings) itself.
# ---------------------------------------------------------------------------
"${PY}" - "${REPO_ROOT}" <<'PYEOF'
import hashlib
import json
import re
import sys
from pathlib import Path
from typing import Optional

repo_root = Path(sys.argv[1]).resolve()
violations = []   # list of (check_label, detail) -> causes FAIL
warnings = []      # list of str -> printed but does not fail the build
notes = []         # list of str -> informational (e.g. skipped optional checks)


def fail(check, detail):
    violations.append((check, detail))


def warn(msg):
    warnings.append(msg)


def note(msg):
    notes.append(msg)


# ---------------------------------------------------------------------------
# Derive N = number of agents/*.md files. This is the single source of truth
# every other surface is checked against.
# ---------------------------------------------------------------------------
agents_dir = repo_root / "agents"
agent_files = sorted(agents_dir.glob("*.md"))
N = len(agent_files)
agent_names = {f.stem for f in agent_files}

if N == 0:
    print(f"FAIL: no agents/*.md files found under {agents_dir}")
    sys.exit(1)

ARABIC_INDIC_DIGITS = "٠١٢٣٤٥٦٧٨٩"


def to_arabic_indic(n: int) -> str:
    return "".join(ARABIC_INDIC_DIGITS[int(d)] for d in str(n))


N_AR = to_arabic_indic(N)


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def require_file(path: Path, check: str) -> Optional[str]:
    if not path.exists():
        fail(check, f"{path.relative_to(repo_root)}: file not found")
        return None
    return read(path)


# ---------------------------------------------------------------------------
# Check 1 — Count drift across every surface that restates the agent count.
# ---------------------------------------------------------------------------
CHECK1 = "1. Count drift"


def check_text_contains(path: Path, needle: str, where: str):
    text = require_file(path, CHECK1)
    if text is None:
        return
    if needle not in text:
        fail(
            CHECK1,
            f"{path.relative_to(repo_root)} ({where}): "
            f"expected to find {needle!r} (N={N}), but it was not present",
        )


def check_regex_matches_N(path: Path, pattern: str, where: str, expected_value: str):
    """Find all occurrences of `pattern` (must have one capture group) and
    assert every captured value equals expected_value. Fails if zero matches
    are found (the surface no longer states a count at all) or if any
    captured value disagrees with expected_value."""
    text = require_file(path, CHECK1)
    if text is None:
        return
    matches = re.findall(pattern, text)
    if not matches:
        fail(
            CHECK1,
            f"{path.relative_to(repo_root)} ({where}): pattern not found "
            f"(expected a count of {expected_value})",
        )
        return
    for m in matches:
        if m != expected_value:
            fail(
                CHECK1,
                f"{path.relative_to(repo_root)} ({where}): expected {expected_value}, found {m}",
            )


# README.md
readme = repo_root / "README.md"
check_regex_matches_N(
    readme, r"(\d+)\s+specialist AI engineers", "N specialist AI engineers copy", str(N)
)
check_regex_matches_N(
    readme, r"badge/agents-(\d+)-C9A84C", "agents badge shield", str(N)
)
check_regex_matches_N(
    readme, r"##\s+.*roster \((\d+) agents\)", "roster (N agents) heading", str(N)
)

# .claude-plugin/plugin.json
plugin_json_path = repo_root / ".claude-plugin" / "plugin.json"
plugin_text = require_file(plugin_json_path, CHECK1)
if plugin_text is not None:
    m = re.search(r"team of (\d+) specialist Claude Code subagents", plugin_text)
    if not m:
        fail(CHECK1, f"{plugin_json_path.relative_to(repo_root)}: agent-count phrase not found in description")
    elif m.group(1) != str(N):
        fail(CHECK1, f"{plugin_json_path.relative_to(repo_root)}: expected {N}, found {m.group(1)}")

# .claude-plugin/marketplace.json
marketplace_json_path = repo_root / ".claude-plugin" / "marketplace.json"
marketplace_text = require_file(marketplace_json_path, CHECK1)
if marketplace_text is not None:
    found_any = False
    for m in re.finditer(r"(\d+)\s+specialist (?:AI engineers|subagents)", marketplace_text):
        found_any = True
        if m.group(1) != str(N):
            fail(CHECK1, f"{marketplace_json_path.relative_to(repo_root)}: expected {N}, found {m.group(1)}")
    if not found_any:
        fail(CHECK1, f"{marketplace_json_path.relative_to(repo_root)}: agent-count phrase not found")

# docs/WHAT-IS-SAEED.md — English + Arabic
what_is_md = repo_root / "docs" / "WHAT-IS-SAEED.md"
check_regex_matches_N(what_is_md, r"\*\*(\d+) specialist AI agents\*\*", "EN bold agent count", str(N))
check_regex_matches_N(what_is_md, r"### The team \((\d+) specialists\)", "EN team heading", str(N))
check_text_contains(what_is_md, f"**{N_AR} وكيلاً ذكائياً متخصصاً**", "AR bold agent count")
check_text_contains(what_is_md, f"### الفريق ({N_AR} متخصصاً)", "AR team heading")

# docs/CHEATSHEET.md — English + Arabic
cheatsheet_md = repo_root / "docs" / "CHEATSHEET.md"
check_regex_matches_N(cheatsheet_md, r"all (\d+) specialists you", "EN intro copy", str(N))
check_regex_matches_N(cheatsheet_md, r"## .*The (\d+) specialists", "EN specialists heading", str(N))
check_text_contains(cheatsheet_md, f"الـ{N_AR}", "AR specialists reference")

# docs/what-is-saeed.html — meta description, hero, chip, org-section heading,
# Arabic hero, and the SVG donut numeral.
html_path = repo_root / "docs" / "what-is-saeed.html"
check_regex_matches_N(
    html_path,
    r'<meta name="description" content="[^"]*?self-improving team of (\d+) specialist AI engineers',
    "meta description",
    str(N),
)
check_regex_matches_N(
    html_path, r"(\d+) specialist AI engineers</strong> that design", "hero copy", str(N)
)
check_regex_matches_N(html_path, r'<span class="chip">(\d+) Agents</span>', "hero chip", str(N))
check_regex_matches_N(
    html_path, r"<h2>(\d+) specialists, organised like a real org\.</h2>", "org-section heading", str(N)
)
check_text_contains(html_path, f"<strong style=\"color:#fff\">{N_AR} وكيلاً ذكائياً متخصصاً</strong>", "Arabic hero copy")
check_regex_matches_N(
    html_path,
    r'font-size="34" fill="#0A1628">(\d+)</text>',
    "SVG donut numeral",
    str(N),
)

# .saeed/state.json roster_agents — OPTIONAL: .saeed/ is per-project runtime
# state and gitignored, so a fresh clone / CI checkout legitimately has none.
# When the file exists (a maintainer's working copy), drift still fails hard.
state_json_path = repo_root / ".saeed" / "state.json"
state_text = read(state_json_path) if state_json_path.exists() else None
if state_text is None:
    note(".saeed/state.json absent (gitignored runtime state) — roster_agents drift check skipped")
if state_text is not None:
    try:
        state = json.loads(state_text)
        roster_agents = state.get("roster_agents")
        if roster_agents is None:
            fail(CHECK1, f"{state_json_path.relative_to(repo_root)}: 'roster_agents' key missing")
        elif roster_agents != N:
            fail(
                CHECK1,
                f"{state_json_path.relative_to(repo_root)}: roster_agents expected {N}, found {roster_agents}",
            )
    except json.JSONDecodeError as e:
        fail(CHECK1, f"{state_json_path.relative_to(repo_root)}: invalid JSON ({e}) — checked separately in JSON validity too")


# ---------------------------------------------------------------------------
# Check 2 — Frontmatter integrity for every agents/*.md
# ---------------------------------------------------------------------------
CHECK2 = "2. Frontmatter integrity"
FRONTMATTER_RE = re.compile(r"\A---\n(.*?)\n---\n", re.S)

for f in agent_files:
    text = read(f)
    m = FRONTMATTER_RE.match(text)
    if not m:
        fail(CHECK2, f"{f.relative_to(repo_root)}: no YAML frontmatter block found at top of file")
        continue
    fm = m.group(1)
    name_m = re.search(r"^name:\s*(\S+)\s*$", fm, re.M)
    desc_m = re.search(r"^description:\s*\S", fm, re.M)
    model_m = re.search(r"^model:\s*(\S+)\s*$", fm, re.M)

    if not name_m:
        fail(CHECK2, f"{f.relative_to(repo_root)}: missing 'name:' in frontmatter")
    if not desc_m:
        fail(CHECK2, f"{f.relative_to(repo_root)}: missing 'description:' in frontmatter")
    if not model_m:
        fail(CHECK2, f"{f.relative_to(repo_root)}: missing 'model:' in frontmatter")

    if name_m:
        expected_name = f.stem
        found_name = name_m.group(1)
        if found_name != expected_name:
            fail(
                CHECK2,
                f"{f.relative_to(repo_root)}: name: {found_name!r} does not match filename {expected_name!r}",
            )


# ---------------------------------------------------------------------------
# Check 3 — Model-tier tally vs .saeed/models.md
# ---------------------------------------------------------------------------
CHECK3 = "3. Model-tier tally"

opus_count = 0
sonnet_count = 0
other_models = []

for f in agent_files:
    text = read(f)
    m = FRONTMATTER_RE.match(text)
    if not m:
        continue  # already reported as a check-2 violation
    fm = m.group(1)
    model_m = re.search(r"^model:\s*(\S+)\s*$", fm, re.M)
    if not model_m:
        continue  # already reported as a check-2 violation
    model_val = model_m.group(1)
    if model_val == "opus":
        opus_count += 1
    elif model_val == "sonnet":
        sonnet_count += 1
    else:
        other_models.append((f.relative_to(repo_root), model_val))

# OPTIONAL for the same reason as .saeed/state.json above.
models_md_path = repo_root / ".saeed" / "models.md"
models_text = read(models_md_path) if models_md_path.exists() else None
if models_text is None:
    note(".saeed/models.md absent (gitignored runtime state) — model-tally drift check skipped")
if models_text is not None:
    opus_m = re.search(r"Opus \((\d+)\)", models_text)
    sonnet_m = re.search(r"Sonnet \((\d+)\)", models_text)
    if not opus_m:
        fail(CHECK3, f"{models_md_path.relative_to(repo_root)}: could not find 'Opus (N)' tally heading")
    else:
        stated_opus = int(opus_m.group(1))
        if stated_opus != opus_count:
            fail(
                CHECK3,
                f"{models_md_path.relative_to(repo_root)}: states {stated_opus} opus, "
                f"but agents/*.md frontmatter has {opus_count}",
            )
    if not sonnet_m:
        fail(CHECK3, f"{models_md_path.relative_to(repo_root)}: could not find 'Sonnet (N)' tally heading")
    else:
        stated_sonnet = int(sonnet_m.group(1))
        if stated_sonnet != sonnet_count:
            fail(
                CHECK3,
                f"{models_md_path.relative_to(repo_root)}: states {stated_sonnet} sonnet, "
                f"but agents/*.md frontmatter has {sonnet_count}",
            )

if other_models:
    for rel, val in other_models:
        fail(CHECK3, f"{rel}: unexpected model tier {val!r} (expected 'opus' or 'sonnet')")

# Cross-check the per-tier tallies stated in the docs/what-is-saeed.html
# "Model mix" legend against the actual frontmatter counts. This is a distinct
# surface from the agent-count donut numeral (Check 1); it previously drifted
# undetected — cycle 4 found the Sonnet legend row stale at 39 (=53 total) five
# lines under a "54" donut, in this gate's original blind spot.
html_mix_path = repo_root / "docs" / "what-is-saeed.html"
html_mix_text = require_file(html_mix_path, CHECK3)
if html_mix_text is not None:
    legend_opus = re.search(r"(\d+)\s+top-tier \(Opus\)", html_mix_text)
    legend_sonnet = re.search(r"(\d+)\s+mid-tier \(Sonnet\)", html_mix_text)
    if not legend_opus:
        fail(CHECK3, f"{html_mix_path.relative_to(repo_root)}: 'N top-tier (Opus)' Model-mix legend row not found")
    elif int(legend_opus.group(1)) != opus_count:
        fail(CHECK3, f"{html_mix_path.relative_to(repo_root)}: Model-mix legend states {legend_opus.group(1)} opus, but agents/*.md frontmatter has {opus_count}")
    if not legend_sonnet:
        fail(CHECK3, f"{html_mix_path.relative_to(repo_root)}: 'N mid-tier (Sonnet)' Model-mix legend row not found")
    elif int(legend_sonnet.group(1)) != sonnet_count:
        fail(CHECK3, f"{html_mix_path.relative_to(repo_root)}: Model-mix legend states {legend_sonnet.group(1)} sonnet, but agents/*.md frontmatter has {sonnet_count}")


# ---------------------------------------------------------------------------
# Check 4 — JSON validity
# ---------------------------------------------------------------------------
CHECK4 = "4. JSON validity"

json_files = [
    repo_root / ".claude-plugin" / "plugin.json",
    repo_root / ".claude-plugin" / "marketplace.json",
    repo_root / "hooks" / "hooks.json",
]
# Runtime state is validated only when present (gitignored on a fresh clone).
if (repo_root / ".saeed" / "state.json").exists():
    json_files.append(repo_root / ".saeed" / "state.json")

for jf in json_files:
    text = require_file(jf, CHECK4)
    if text is None:
        continue
    try:
        json.loads(text)
    except json.JSONDecodeError as e:
        fail(CHECK4, f"{jf.relative_to(repo_root)}: invalid JSON — {e}")


# ---------------------------------------------------------------------------
# Check 5 — Handoff reference resolution
# ---------------------------------------------------------------------------
CHECK5 = "5. Handoff reference resolution"
HANDOFFS_SECTION_RE = re.compile(r"^## Handoffs\n(.*?)(?=\n## |\Z)", re.S | re.M)
BACKTICK_RE = re.compile(r"`([^`\n]+)`")

for f in agent_files:
    text = read(f)
    m = HANDOFFS_SECTION_RE.search(text)
    if not m:
        fail(CHECK5, f"{f.relative_to(repo_root)}: no '## Handoffs' section found")
        continue
    section = m.group(1)
    for ref in BACKTICK_RE.findall(section):
        # A handoff reference is a single bare agent-name token (no spaces,
        # no slashes/paths, no code-punctuation) — skip anything that is
        # clearly a code identifier / path / flag rather than an agent name.
        if not re.fullmatch(r"[a-z0-9][a-z0-9-]*", ref):
            continue
        if ref not in agent_names:
            fail(
                CHECK5,
                f"{f.relative_to(repo_root)}: Handoffs references `{ref}`, "
                f"but agents/{ref}.md does not exist",
            )


# ---------------------------------------------------------------------------
# Check 6 (warning only) — Stack context paragraph drift detector
# ---------------------------------------------------------------------------
STACK_SECTION_RE = re.compile(r"^## Stack context\n(.*?)(?=\n## |\Z)", re.S | re.M)
stack_hashes = {}

for f in agent_files:
    text = read(f)
    m = STACK_SECTION_RE.search(text)
    if not m:
        continue  # not every agent carries a Stack context section (e.g. pure governance/meta roles)
    normalized = " ".join(m.group(1).split())
    h = hashlib.sha256(normalized.encode("utf-8")).hexdigest()[:12]
    stack_hashes.setdefault(h, []).append(f.relative_to(repo_root))

if len(stack_hashes) > 1:
    warn(
        f"Stack context drift: {len(stack_hashes)} distinct whitespace-normalized "
        f"variants found among {sum(len(v) for v in stack_hashes.values())} agents with a "
        f"'## Stack context' section:"
    )
    for h, files in stack_hashes.items():
        warn(f"  variant {h}: {len(files)} agent(s) -> {', '.join(str(x) for x in files[:5])}"
             + (" ..." if len(files) > 5 else ""))


# ---------------------------------------------------------------------------
# Check 7 — Governance structure (self-governance protocol, cycle 5).
# The mechanical FLOOR under the "park, never deadlock" keystone: the parking
# anchor must exist so an unattended steward never writes to a missing section,
# and the autonomy sentinel must be well-formed so its level is unambiguous.
# The SEMANTIC question — "was the RIGHT thing parked / did a reopen cite a
# trigger?" — is a judgment call, enforced by self-eval-critic's Governance
# check, not here. Both sub-checks are guarded on file existence so a fresh
# clone without a populated .saeed/ is not failed by them.
# ---------------------------------------------------------------------------
CHECK7 = "7. Governance structure"

# 7a — .saeed/AUTONOMY, if present, must name a known level on its first
# non-blank, non-comment line. An absent file is the valid 'supervised'
# default and is intentionally not a failure.
autonomy_path = repo_root / ".saeed" / "AUTONOMY"
if autonomy_path.exists():
    level = None
    for line in read(autonomy_path).splitlines():
        s = line.strip()
        if not s or s.startswith("#"):
            continue
        level = s
        break
    if level is None:
        fail(CHECK7, f"{autonomy_path.relative_to(repo_root)}: no autonomy level found (expected 'supervised' or 'autonomous' on the first non-comment line)")
    elif level not in ("supervised", "autonomous"):
        fail(CHECK7, f"{autonomy_path.relative_to(repo_root)}: unknown autonomy level {level!r} (expected 'supervised' or 'autonomous')")

# 7b — the standing '## Awaiting operator' parking anchor must exist in
# .saeed/queue.md so a supervised unattended pass always has a target to
# append to instead of stalling or silently dropping the item.
queue_path = repo_root / ".saeed" / "queue.md"
if queue_path.exists():
    if "## Awaiting operator" not in read(queue_path):
        fail(CHECK7, f"{queue_path.relative_to(repo_root)}: missing the standing '## Awaiting operator' section (the parking anchor a steward/improve pass writes to instead of deadlocking)")


# ---------------------------------------------------------------------------
# Check 8 — Hook contract (SU-20, absorbed from ECC's tested-hooks practice).
# Every ${CLAUDE_PLUGIN_ROOT} script referenced by hooks/hooks.json must exist,
# and the guardrail hooks must actually behave: known-bad payloads exit 2
# (block) and known-good payloads exit 0 (allow). ECC's lesson: an untested
# hook is a hook that silently fails open forever.
# ---------------------------------------------------------------------------
CHECK8 = "8. Hook contract"

import subprocess
import tempfile

hooks_json_path = repo_root / "hooks" / "hooks.json"
hook_scripts = set()
try:
    hooks_cfg = json.loads(read(hooks_json_path))
    for event, entries in (hooks_cfg.get("hooks") or {}).items():
        for entry in entries:
            for h in entry.get("hooks", []):
                cmd = h.get("command", "")
                for m in re.finditer(r"\$\{CLAUDE_PLUGIN_ROOT\}(/[^\s\"']+)", cmd):
                    rel = m.group(1).lstrip("/")
                    hook_scripts.add(rel)
                    if not (repo_root / rel).exists():
                        fail(CHECK8, f"hooks/hooks.json: referenced script {rel} does not exist")
except (OSError, json.JSONDecodeError):
    fail(CHECK8, "hooks/hooks.json missing or unparseable (also reported by JSON validity)")


def run_hook(script_rel, payload, cwd=None):
    """Pipe payload into a hook script; return its exit code (None on error)."""
    try:
        proc = subprocess.run(
            ["bash", str(repo_root / script_rel)],
            input=payload.encode("utf-8"),
            capture_output=True,
            timeout=30,
            cwd=cwd or repo_root,
        )
        return proc.returncode
    except (OSError, subprocess.TimeoutExpired):
        return None


def expect_hook(script_rel, payload, expected_rc, label, cwd=None):
    if not (repo_root / script_rel).exists():
        return  # existence failure already recorded above
    rc = run_hook(script_rel, payload, cwd=cwd)
    if rc != expected_rc:
        fail(CHECK8, f"{script_rel}: {label} — expected exit {expected_rc}, got {rc}")


GUARD_GIT = "hooks/guard-git-bypass.sh"
expect_hook(GUARD_GIT, '{"tool_input":{"command":"git commit --no-verify -m \\"x\\""}}', 2,
            "must BLOCK `git commit --no-verify`")
expect_hook(GUARD_GIT, '{"tool_input":{"command":"git push --no-verify origin main"}}', 2,
            "must BLOCK `git push --no-verify`")
expect_hook(GUARD_GIT, '{"tool_input":{"command":"git -c core.hooksPath=/dev/null commit -m hi"}}', 2,
            "must BLOCK core.hooksPath override")
expect_hook(GUARD_GIT, '{"tool_input":{"command":"git commit -m \\"docs: mention --no-verify rule\\""}}', 0,
            "must ALLOW --no-verify inside a quoted message")
expect_hook(GUARD_GIT, '{"tool_input":{"command":"git status && ls"}}', 0,
            "must ALLOW ordinary commands")
expect_hook(GUARD_GIT, "not json", 0, "must fail OPEN on unparseable input")

GUARD_CFG = "hooks/guard-config-protection.sh"
with tempfile.TemporaryDirectory() as td:
    existing = Path(td) / ".eslintrc.json"
    existing.write_text("{}", encoding="utf-8")
    expect_hook(GUARD_CFG, json.dumps({"tool_input": {"file_path": str(existing)}}), 2,
                "must BLOCK edits to an existing lint config")
    expect_hook(GUARD_CFG, json.dumps({"tool_input": {"file_path": str(Path(td) / "new" / "biome.json")}}), 0,
                "must ALLOW first-time creation of a lint config")
    expect_hook(GUARD_CFG, json.dumps({"tool_input": {"file_path": str(Path(td) / "src.ts")}}), 0,
                "must ALLOW ordinary files")

BRIEF = "hooks/session-brief.sh"
with tempfile.TemporaryDirectory() as td:
    proj = Path(td) / "proj"
    (proj / ".saeed").mkdir(parents=True)
    (proj / ".saeed" / "queue.md").write_text(
        "- T1 | x | TODO\n\n## Awaiting operator\n- parked\n", encoding="utf-8")
    if (repo_root / BRIEF).exists():
        try:
            proc = subprocess.run(["bash", str(repo_root / BRIEF)], input=b"{}",
                                  capture_output=True, timeout=30, cwd=proj)
            if proc.returncode != 0:
                fail(CHECK8, f"{BRIEF}: expected exit 0 with a .saeed/ dir, got {proc.returncode}")
            else:
                out = json.loads(proc.stdout.decode("utf-8"))
                ctx = out["hookSpecificOutput"]["additionalContext"]
                if "SAEED session brief" not in ctx or out["hookSpecificOutput"]["hookEventName"] != "SessionStart":
                    fail(CHECK8, f"{BRIEF}: SessionStart JSON present but malformed")
        except (OSError, subprocess.TimeoutExpired, json.JSONDecodeError, KeyError) as e:
            fail(CHECK8, f"{BRIEF}: brief output not valid SessionStart JSON ({e})")
        # Without .saeed/ it must stay silent (exit 0, empty stdout).
        proc = subprocess.run(["bash", str(repo_root / BRIEF)], input=b"{}",
                              capture_output=True, timeout=30, cwd=td)
        if proc.returncode != 0 or proc.stdout.strip():
            fail(CHECK8, f"{BRIEF}: must be silent (exit 0, no stdout) when no .saeed/ exists")


# ---------------------------------------------------------------------------
# Check 9 — Command & skill frontmatter (absorbed from ECC's validate-commands
# / validate-skills CI gates, scaled to this repo).
# ---------------------------------------------------------------------------
CHECK9 = "9. Command & skill frontmatter"

commands_dir = repo_root / "commands"
command_files = sorted(commands_dir.glob("*.md"))
if not command_files:
    fail(CHECK9, "no commands/*.md files found")
for f in command_files:
    text = read(f)
    m = FRONTMATTER_RE.match(text)
    if not m:
        fail(CHECK9, f"{f.relative_to(repo_root)}: no YAML frontmatter block")
        continue
    if not re.search(r"^description:\s*\S", m.group(1), re.M):
        fail(CHECK9, f"{f.relative_to(repo_root)}: missing 'description:' in frontmatter")

skills_dir = repo_root / "skills"
skill_dirs = sorted(p for p in skills_dir.iterdir() if p.is_dir())
if not skill_dirs:
    fail(CHECK9, "no skills/*/ directories found")
for d in skill_dirs:
    skill_md = d / "SKILL.md"
    if not skill_md.exists() or not read(skill_md).strip():
        fail(CHECK9, f"skills/{d.name}/SKILL.md missing or empty")
        continue
    text = read(skill_md)
    m = FRONTMATTER_RE.match(text)
    if not m:
        fail(CHECK9, f"skills/{d.name}/SKILL.md: no YAML frontmatter block")
        continue
    fm = m.group(1)
    name_m = re.search(r"^name:\s*(\S+)\s*$", fm, re.M)
    if not name_m:
        fail(CHECK9, f"skills/{d.name}/SKILL.md: missing 'name:' in frontmatter")
    elif name_m.group(1) != d.name:
        fail(CHECK9, f"skills/{d.name}/SKILL.md: name {name_m.group(1)!r} != directory name {d.name!r}")
    desc_m = re.search(r"^description:\s*(\S.*)$", fm, re.M)
    if not desc_m:
        fail(CHECK9, f"skills/{d.name}/SKILL.md: missing 'description:' in frontmatter")
    elif desc_m.group(1).strip().startswith("|"):
        # ECC lesson: literal block scalars preserve newlines and break
        # flat-table renderers keyed off the description.
        fail(CHECK9, f"skills/{d.name}/SKILL.md: description uses a literal block scalar ('|') — use a single line or folded scalar")


# ---------------------------------------------------------------------------
# Report
# ---------------------------------------------------------------------------
print("=" * 78)
print(f"SU-19 fleet validation — derived N = {N} agents (agents/*.md)")
print("=" * 78)

for n_msg in notes:
    print(f"NOTE: {n_msg}")
for w in warnings:
    print(f"WARNING: {w}")

if violations:
    print()
    print(f"FAIL — {len(violations)} violation(s) found:")
    print()
    by_check = {}
    for check, detail in violations:
        by_check.setdefault(check, []).append(detail)
    for check in sorted(by_check):
        print(f"[{check}]")
        for detail in by_check[check]:
            print(f"  - {detail}")
        print()
    print("=" * 78)
    print(f"RESULT: FAIL ({len(violations)} violation(s))")
    print("=" * 78)
    sys.exit(1)
else:
    print()
    print("All checks passed:")
    print(f"  1. Count drift            — N={N} consistent across README, plugin.json,")
    print(f"                              marketplace.json, WHAT-IS-SAEED.md (EN/AR),")
    print(f"                              CHEATSHEET.md (EN/AR), what-is-saeed.html")
    print(f"                              (incl. SVG donut), and .saeed/state.json")
    print(f"  2. Frontmatter integrity  — {N}/{N} agents have name/description/model,")
    print(f"                              name matches filename")
    print(f"  3. Model-tier tally       — {opus_count} opus / {sonnet_count} sonnet matches .saeed/models.md")
    print(f"                              and the what-is-saeed.html Model-mix legend")
    print(f"  4. JSON validity          — plugin.json, marketplace.json, hooks.json,")
    print(f"                              .saeed/state.json all parse")
    print(f"  5. Handoff references     — all backtick agent references resolve")
    print(f"  7. Governance structure   — .saeed/AUTONOMY level valid + queue.md")
    print(f"                              carries the '## Awaiting operator' anchor")
    print(f"  8. Hook contract          — hooks.json scripts exist; guardrails block")
    print(f"                              bypass payloads and allow benign ones;")
    print(f"                              session brief emits valid SessionStart JSON")
    print(f"  9. Cmd/skill frontmatter  — {len(command_files)} commands have description;")
    print(f"                              {len(skill_dirs)} skills have matching name + description")
    print("=" * 78)
    print("RESULT: PASS")
    print("=" * 78)
    sys.exit(0)
PYEOF
exit $?
