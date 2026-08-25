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
#  10. Cross-reference resolution — every `skills/<name>/SKILL.md` reference
#                        found anywhere under agents/, commands/, skills/,
#                        hooks/, docs/, or README.md must resolve to a real
#                        file on disk; and (when .saeed/state.json exists)
#                        its `skills` array must match the actual skills/*/
#                        directories in both directions. Closes the blind
#                        spot Checks 5 and 9 structurally cannot see: a canon
#                        that is referenced but was never authored. (B7-NEW —
#                        cycle 9 wired 28 references to a nonexistent canon
#                        across 24 files and this validator stayed green the
#                        whole time.)
#  11. Canon reference form — no doctrine file (skills/, agents/, commands/,
#                        hooks/) carries a bare backticked `skills/<name>`
#                        without /SKILL.md, and none carries a line-anchored
#                        `SKILL.md:<digits>` cross-reference. Check 10's
#                        pattern requires /SKILL.md, so a MALFORMED reference
#                        — including a typo'd canon name — never matched it
#                        and shipped green; line anchors rot silently and the
#                        two this cycle shipped pointed at the wrong rule.
#  12. Version parity  — .claude-plugin/plugin.json is the version of record;
#                        CHANGELOG.md's newest `## <version>` heading, the
#                        README badge, and (when present) .saeed/state.json
#                        must all agree with it. Third occurrence of the
#                        stale-bookkeeping class: cycle 9's release nearly
#                        shipped plugin.json at 1.9.1 under a 1.10.0 CHANGELOG.
#  13. Capability map   — docs/CAPABILITY-MAP.md exists and every agent it
#                        names as an owner resolves to agents/<name>.md, so a
#                        renamed or retired agent cannot silently orphan a
#                        capability.
#  14. Attribution      — the canonical EN + AR credit strings are intact in
#                        skills/attribution/SKILL.md; every Arabic credit line
#                        in the repo names نبض; no transliterated form of the
#                        company name appears outside the small registry of
#                        files that teach the rule; and the authoring-time
#                        guard hook exists and is wired. Cycle 12: surfaces
#                        shipped ناباد — the Latin "NABAD" respelled in Arabic
#                        letters — because the Arabic string lived in one canon
#                        file and every other surface only said "bilingual".
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
#   0  — all hard checks (1-5, 7-14) passed. Check 6 is advisory and never
#        fails the build; it only prints a warning.
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
fable_count = 0
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
    elif model_val == "fable":
        fable_count += 1
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
    # Fable is a legitimate third tier (MS-1, cycle 10). The heading is required
    # exactly when the fleet carries fable agents; a stated tally must match.
    fable_m = re.search(r"Fable \((\d+)\)", models_text)
    if fable_count > 0 and not fable_m:
        fail(
            CHECK3,
            f"{models_md_path.relative_to(repo_root)}: could not find 'Fable (N)' tally heading "
            f"while agents/*.md frontmatter has {fable_count} fable",
        )
    elif fable_m and int(fable_m.group(1)) != fable_count:
        fail(
            CHECK3,
            f"{models_md_path.relative_to(repo_root)}: states {fable_m.group(1)} fable, "
            f"but agents/*.md frontmatter has {fable_count}",
        )

if other_models:
    for rel, val in other_models:
        fail(CHECK3, f"{rel}: unexpected model tier {val!r} (expected 'opus', 'sonnet', or 'fable')")

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
    legend_fable = re.search(r"(\d+)\s+apex-tier \(Fable\)", html_mix_text)
    if fable_count > 0 and not legend_fable:
        fail(CHECK3, f"{html_mix_path.relative_to(repo_root)}: 'N apex-tier (Fable)' Model-mix legend row not found while agents/*.md frontmatter has {fable_count} fable")
    elif legend_fable and int(legend_fable.group(1)) != fable_count:
        fail(CHECK3, f"{html_mix_path.relative_to(repo_root)}: Model-mix legend states {legend_fable.group(1)} fable, but agents/*.md frontmatter has {fable_count}")


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

GUARD_ATTRIB = "hooks/guard-attribution-canon.sh"
# Use vs mention, the transliteration trap, and the read path all have to hold:
# a guard that blocks `grep ناباد` would break the only way to diagnose the
# defect, and one that fires inside نبادل/نبادر would block ordinary Arabic copy.
expect_hook(GUARD_ATTRIB,
            json.dumps({"tool_name": "Write", "tool_input": {
                "file_path": "/tmp/x/README.md",
                "content": "تطوير ناباد لحلول الكمبيوتر ذ.م.م."}}),
            2, "must BLOCK a transliterated company name in a Write")
expect_hook(GUARD_ATTRIB,
            json.dumps({"tool_name": "Edit", "tool_input": {
                "file_path": "/tmp/x/Footer.tsx",
                "new_string": "<p>تطوير نباد لحلول الكمبيوتر</p>"}}),
            2, "must BLOCK a transliterated name in an Edit new_string")
expect_hook(GUARD_ATTRIB,
            json.dumps({"tool_name": "MultiEdit", "tool_input": {
                "file_path": "/tmp/x/ar.md",
                "edits": [{"new_string": "fine"}, {"new_string": "شركة ناباد"}]}}),
            2, "must BLOCK a transliterated name in any MultiEdit edit")
expect_hook(GUARD_ATTRIB,
            json.dumps({"tool_name": "Write", "tool_input": {
                "file_path": "/tmp/x/ar.json",
                "content": "تطوير نابض لحلول الكمبيوتر ذ.م.م."}}),
            2, "must BLOCK a real Arabic word used in company-name position")
expect_hook(GUARD_ATTRIB,
            json.dumps({"tool_name": "Bash", "tool_input": {
                "command": 'echo "تطوير ناباد" >> README.md'}}),
            2, "must BLOCK a transliterated name written through a shell redirect")
expect_hook(GUARD_ATTRIB,
            json.dumps({"tool_name": "Write", "tool_input": {
                "file_path": "/tmp/x/README.md",
                "content": "تطوير نبض لحلول الكمبيوتر ذ.م.م."}}),
            0, "must ALLOW the canonical Arabic credit line")
expect_hook(GUARD_ATTRIB,
            json.dumps({"tool_name": "Write", "tool_input": {
                "file_path": "/tmp/x/doc.md",
                "content": "انتقل إلى نبض الوصاية لإبقاء المشروع حيّاً"}}),
            0, "must ALLOW نبض used as an ordinary noun")
expect_hook(GUARD_ATTRIB,
            json.dumps({"tool_name": "Write", "tool_input": {
                "file_path": "/tmp/x/copy.md",
                "content": "نبادل الخبرات ونبادر إلى العمل، والقلب نابض بالحياة"}}),
            0, "must ALLOW نبادل/نبادر/نابض in ordinary copy (no bare-substring matching)")
expect_hook(GUARD_ATTRIB,
            json.dumps({"tool_name": "Bash", "tool_input": {"command": "grep -rn ناباد ."}}),
            0, "must ALLOW reading/grepping for the wrong form — that is how it is diagnosed")
expect_hook(GUARD_ATTRIB,
            json.dumps({"tool_name": "Write", "tool_input": {
                "file_path": str(repo_root / "skills" / "attribution" / "SKILL.md"),
                "content": "never write ناباد"}}),
            0, "must ALLOW the canon file itself to name the banned forms")
expect_hook(GUARD_ATTRIB, "not json", 0, "must fail OPEN on unparseable input")

GUARD_TDD = "hooks/guard-tdd-mode.sh"
if (repo_root / GUARD_TDD).exists():
    # Fixture repo path deliberately contains a space, mirroring this
    # repo's own path ("S.A.E.E.D." lives under a space-bearing iCloud
    # path) — a `tempfile.TemporaryDirectory()` with no space in it is
    # green for the wrong reason and misses quote-truncation bugs in the
    # hook's target-path extraction.
    with tempfile.TemporaryDirectory(prefix="saeed tdd guard ") as td:
        repo = Path(td) / "repo with space"
        (repo / "src").mkdir(parents=True)
        (repo / ".saeed").mkdir(parents=True)
        subprocess.run(["git", "init", "-q"], cwd=repo, capture_output=True, timeout=10)
        subprocess.run(["git", "config", "user.email", "tdd-fixture@saeed.local"], cwd=repo, capture_output=True, timeout=10)
        subprocess.run(["git", "config", "user.name", "SAEED TDD Fixture"], cwd=repo, capture_output=True, timeout=10)
        src_file = repo / "src" / "foo.ts"
        src_file.write_text("export const foo = 1;\n", encoding="utf-8")
        subprocess.run(["git", "add", "-A"], cwd=repo, capture_output=True, timeout=10)
        subprocess.run(["git", "commit", "-q", "-m", "seed"], cwd=repo, capture_output=True, timeout=10)

        # Sentinel absent: even a would-be-blocking payload must stay silent.
        expect_hook(GUARD_TDD, json.dumps({"tool_name": "Write", "tool_input": {"file_path": str(src_file)}}),
                    0, "must stay silent (no .saeed/TDD sentinel)", cwd=repo)

        (repo / ".saeed" / "TDD").write_text("enforce\n", encoding="utf-8")

        # 1. enforce-mode bypass write (echo redirect into logic-bearing source,
        #    properly quoted because the path contains a space) -> BLOCK.
        #    This is the code-reviewer's exact repro for the space-truncation bug:
        #    a whitespace-regex target extraction truncates the quoted path at its
        #    first space, the extension check never sees `.ts`, and the bypass
        #    this hook exists to police sails through in enforce mode.
        expect_hook(GUARD_TDD, json.dumps({"tool_name": "Bash", "tool_input": {"command": f'echo "x" >> "{src_file}"'}}),
                    2, "enforce mode must BLOCK a quoted, space-containing echo-redirect bypass write into logic-bearing source", cwd=repo)

        # 2. enforce-mode source edit with no test file in the change-set -> BLOCK.
        expect_hook(GUARD_TDD, json.dumps({"tool_name": "Write", "tool_input": {"file_path": str(src_file)}}),
                    2, "enforce mode must BLOCK a source edit with no test change in the change-set", cwd=repo)

        # 3. sentinel tamper (editing the existing .saeed/TDD file itself) -> BLOCK.
        expect_hook(GUARD_TDD, json.dumps({"tool_name": "Edit", "tool_input": {"file_path": str(repo / ".saeed" / "TDD")}}),
                    2, "must BLOCK edits to an existing .saeed/TDD sentinel", cwd=repo)

        # 3b. sentinel tamper through the Bash channel (NIT N3) -> BLOCK, both shapes.
        expect_hook(GUARD_TDD, json.dumps({"tool_name": "Bash", "tool_input": {"command": f'rm "{repo}/.saeed/TDD"'}}),
                    2, "must BLOCK `rm` targeting the existing .saeed/TDD sentinel via Bash", cwd=repo)
        expect_hook(GUARD_TDD, json.dumps({"tool_name": "Bash", "tool_input": {"command": f'echo off > "{repo}/.saeed/TDD"'}}),
                    2, "must BLOCK a redirect-overwrite of the existing .saeed/TDD sentinel via Bash", cwd=repo)
        expect_hook(GUARD_TDD, json.dumps({"tool_name": "Bash", "tool_input": {"command": "git status && ls"}}),
                    0, "must ALLOW an ordinary Bash command that does not touch the sentinel", cwd=repo)

        # 4. benign edit accompanied by a test change (untracked test file present) -> ALLOW.
        (repo / "src" / "foo.test.ts").write_text("test('x', () => {});\n", encoding="utf-8")
        expect_hook(GUARD_TDD, json.dumps({"tool_name": "Write", "tool_input": {"file_path": str(src_file)}}),
                    0, "must ALLOW a source edit when a test file is present in the change-set", cwd=repo)

        # 5. non-JSON input -> fail open.
        expect_hook(GUARD_TDD, "not json", 0, "must fail OPEN on unparseable input", cwd=repo)


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
# Check 10 — Cross-reference resolution (B7-NEW). Both this cycle's gates
# independently found that cycle 9 wired 28 references to a canon that did
# not exist, across 24 files, while this validator stayed green the entire
# time: Check 9 only enumerates skills/*/ directories that DO exist (so an
# absent canon is invisible to it), and Check 5 only resolves backtick tokens
# inside a '## Handoffs' section (so a prose reference anywhere else is
# invisible to it too). A referenced-but-absent canon fell squarely between
# them. This check closes that hole directly by scanning every surface a
# canon reference can appear on and resolving it against the real filesystem.
# ---------------------------------------------------------------------------
CHECK10 = "10. Cross-reference resolution"

SKILL_REF_RE = re.compile(r"skills/([A-Za-z0-9_-]+)/SKILL\.md")
CROSSREF_ROOTS = ["agents", "commands", "skills", "hooks", "docs"]

crossref_files = []
for root_name in CROSSREF_ROOTS:
    root_dir = repo_root / root_name
    if root_dir.exists():
        crossref_files.extend(sorted(p for p in root_dir.rglob("*") if p.is_file()))
readme_path = repo_root / "README.md"
if readme_path.exists():
    crossref_files.append(readme_path)

actual_skill_dirs = {p.name for p in skills_dir.iterdir() if p.is_dir()} if skills_dir.exists() else set()

# 10a — every skills/<name>/SKILL.md reference found in the fleet must
# resolve to a real file. This is the check that would have caught this
# cycle's defect on day one: no enumeration of what exists, just resolution
# of what is claimed.
for f in crossref_files:
    try:
        text = read(f)
    except (UnicodeDecodeError, OSError):
        continue
    for name in SKILL_REF_RE.findall(text):
        if name not in actual_skill_dirs:
            fail(
                CHECK10,
                f"{f.relative_to(repo_root)}: references skills/{name}/SKILL.md, "
                f"but skills/{name}/SKILL.md does not exist on disk",
            )

# 10b — .saeed/state.json 'skills' array vs skills/*/ directories, checked in
# BOTH directions (no phantom entries, no unlisted canons). OPTIONAL for the
# same reason as the other .saeed/ checks above: it is per-project gitignored
# runtime state, so a fresh clone/CI checkout legitimately has none.
if state_text is None:
    note(".saeed/state.json absent (gitignored runtime state) — skills-roster cross-check skipped")
else:
    try:
        state10 = json.loads(state_text)
        stated_skills = set(state10.get("skills") or [])
        phantom = sorted(stated_skills - actual_skill_dirs)
        unlisted = sorted(actual_skill_dirs - stated_skills)
        for name in phantom:
            fail(
                CHECK10,
                f".saeed/state.json: 'skills' array lists {name!r}, "
                f"but skills/{name}/SKILL.md does not exist on disk",
            )
        for name in unlisted:
            fail(
                CHECK10,
                f".saeed/state.json: 'skills' array is missing {name!r}, "
                f"but skills/{name}/ exists on disk",
            )
    except json.JSONDecodeError:
        pass  # already reported by Check 1 / Check 4


# ---------------------------------------------------------------------------
# Check 11 — Canon reference FORM. Check 10 resolves well-formed references;
# a malformed one slips past it silently, which is exactly where cycle 9's
# last two blocking defects hid. Two shapes, both mechanical:
#   11a  a bare backticked `skills/<name>` with no /SKILL.md. Check 10's
#        pattern requires /SKILL.md, so it never matches a bare reference —
#        meaning a misspelled canon name currently resolves to nothing and
#        ships green. Both the wrong-form and the typo case are caught here.
#   11b  a line-anchored `SKILL.md:<digits>` cross-reference — line numbers in
#        a neighbouring canon have no stability guarantee, and the ones this
#        cycle shipped pointed at the wrong rule before they even rotted.
# Scoped to the doctrine surfaces (skills/agents/commands/hooks): docs and
# CHANGELOG legitimately quote grep output with line numbers. There is no
# fenced-code exemption, per canon-craft's own rule that exemption clauses
# don't scope: a canon illustrating a bad form writes it in a shape the rule
# cannot match (angle-bracket placeholders like `skills/<name>`), rather than
# carving out a region where a real violation could hide.
# ---------------------------------------------------------------------------
CHECK11 = "11. Canon reference form"

BARE_SKILL_REF_RE = re.compile(r"`skills/([A-Za-z0-9_-]+)`")
ANCHORED_SKILL_REF_RE = re.compile(r"SKILL\.md:\d+")
DOCTRINE_ROOTS = ["skills", "agents", "commands", "hooks"]

doctrine_files = []
for root_name in DOCTRINE_ROOTS:
    root_dir = repo_root / root_name
    if root_dir.exists():
        doctrine_files.extend(sorted(p for p in root_dir.rglob("*") if p.is_file()))

for f in doctrine_files:
    try:
        text = read(f)
    except (UnicodeDecodeError, OSError):
        continue
    rel = f.relative_to(repo_root)
    for name in sorted(set(BARE_SKILL_REF_RE.findall(text))):
        # Every bare backticked `skills/<name>` is a defect, whether the name
        # is a real canon (wrong form) or not (a typo no other check can see:
        # Check 10's pattern requires /SKILL.md, so it never matches a bare
        # ref at all — a misspelled canon reference would otherwise ship green).
        if name in actual_skill_dirs:
            fail(
                CHECK11,
                f"{rel}: references `skills/{name}` without /SKILL.md — "
                f"use the full `skills/{name}/SKILL.md` path form",
            )
        else:
            fail(
                CHECK11,
                f"{rel}: references `skills/{name}`, which is neither a canon "
                f"on disk nor full path form — typo, or a canon that never shipped",
            )
    for m in ANCHORED_SKILL_REF_RE.finditer(text):
        fail(
            CHECK11,
            f"{rel}: line-anchored cross-canon reference ({m.group(0)}) — "
            f"cite the path plus a section name; line numbers rot silently",
        )


# ---------------------------------------------------------------------------
# Check 12 — Version parity. Third occurrence of the stale-bookkeeping class
# this script exists to prevent (cycle 1: Arabic agent count; cycle 3:
# state.json roster count; cycle 9: the release nearly shipped plugin.json at
# 1.9.1 while CHANGELOG.md already announced 1.10.0). plugin.json is the
# version of record; the CHANGELOG's top heading, the README badge, and
# state.json must agree with it.
# ---------------------------------------------------------------------------
CHECK12 = "12. Version parity"

plugin_json_path = repo_root / ".claude-plugin" / "plugin.json"
version_of_record = None
if plugin_json_path.exists():
    try:
        version_of_record = json.loads(read(plugin_json_path)).get("version")
    except json.JSONDecodeError:
        pass  # already reported by Check 4

if version_of_record:
    changelog_path = repo_root / "CHANGELOG.md"
    if changelog_path.exists():
        m = re.search(r"^##\s+(\d+\.\d+\.\d+)", read(changelog_path), re.M)
        if not m:
            fail(CHECK12, "CHANGELOG.md: no '## <version>' release heading found")
        elif m.group(1) != version_of_record:
            fail(
                CHECK12,
                f"CHANGELOG.md: newest release heading is {m.group(1)}, but "
                f"plugin.json (version of record) says {version_of_record}",
            )

    readme_path12 = repo_root / "README.md"
    if readme_path12.exists():
        readme_text = read(readme_path12)
        stale = sorted(
            set(re.findall(r"badge/version-(\d+\.\d+\.\d+)", readme_text))
            | set(re.findall(r'alt="version (\d+\.\d+\.\d+)"', readme_text))
        )
        for found in stale:
            if found != version_of_record:
                fail(
                    CHECK12,
                    f"README.md: version badge reads {found}, but plugin.json "
                    f"(version of record) says {version_of_record}",
                )

    # Optional for the same reason as the other .saeed/ checks: gitignored
    # per-project runtime state, absent in a fresh clone or CI checkout.
    if state_text is None:
        note(".saeed/state.json absent (gitignored runtime state) — version parity check skipped")
    else:
        try:
            state_version = json.loads(state_text).get("version")
            if state_version and state_version != version_of_record:
                fail(
                    CHECK12,
                    f".saeed/state.json: version {state_version}, but plugin.json "
                    f"(version of record) says {version_of_record}",
                )
        except json.JSONDecodeError:
            pass  # already reported by Check 1 / Check 4


# ---------------------------------------------------------------------------
# Check 13 — Capability-map ownership resolution (cycle 11). The coverage
# audit proved an unowned capability is structurally invisible: the roster
# tables inventory agents, so nothing failed while backups, load testing,
# and named compliance regimes had no owner. docs/CAPABILITY-MAP.md is the
# artifact that fails instead — it must exist, and every bare agent token
# it names must resolve to agents/<name>.md, so a retired or renamed agent
# cannot silently leave a capability orphaned.
# ---------------------------------------------------------------------------
CHECK13 = "13. Capability-map ownership"

capmap_path = repo_root / "docs" / "CAPABILITY-MAP.md"
capmap_refs = 0
if not capmap_path.exists():
    fail(CHECK13, "docs/CAPABILITY-MAP.md does not exist — the capability map is doctrine, not decoration")
else:
    capmap_text = read(capmap_path)
    # An owner reference is a bare hyphenated kebab token (every agent name
    # contains a hyphen); paths, commands, and file names carry / : . and
    # are skipped, same shape as Check 5.
    for ref in BACKTICK_RE.findall(capmap_text):
        if not re.fullmatch(r"[a-z0-9]+(?:-[a-z0-9]+)+", ref):
            continue
        capmap_refs += 1
        if ref not in agent_names:
            fail(
                CHECK13,
                f"docs/CAPABILITY-MAP.md: names `{ref}` as an owner, "
                f"but agents/{ref}.md does not exist",
            )
    if capmap_refs == 0:
        fail(CHECK13, "docs/CAPABILITY-MAP.md: contains no resolvable agent-owner references at all")


# ---------------------------------------------------------------------------
# Check 14 — Attribution string canon (cycle 12). The company's Arabic name is
# a WORD — نبض, "pulse" — and "NABAD" is its romanization, not the other way
# round. Surfaces nonetheless shipped ناباد: a letter-for-letter transliteration
# of the Latin name back into Arabic letters. The mechanism was structural, the
# same shape as every other defect class this script exists to prevent: the
# Arabic string lived in exactly ONE file (skills/attribution/SKILL.md) while
# every other surface only said "carry the NABAD credit, bilingual" — so an
# agent writing an Arabic surface without that canon loaded had nothing to copy
# and re-derived the name instead. Doctrine now forbids the derivation and the
# string is carried to the point of use; this check is the mechanical floor,
# and hooks/guard-attribution-canon.sh is the authoring-time twin.
#
# Three rules, in ascending order of generality:
#   (a) the canonical EN + AR strings are present and intact in the canon file;
#   (b) every Arabic credit line in the repo — anything reading
#       "<name> لحلول الكمبيوتر" — names نبض and nothing else. This is the rule
#       that actually catches the defect, and it catches wrong forms nobody
#       thought to ban;
#   (c) the known-wrong forms appear nowhere except as backtick-quoted
#       MENTIONS inside files that teach the rule. Use vs mention is the real
#       distinction: doctrine has to be able to name what it forbids, but only
#       doctrine does, and only in code span form.
# ---------------------------------------------------------------------------
CHECK14 = "14. Attribution string canon"

ATTRIB_CANON_REL = "skills/attribution/SKILL.md"
CANON_EN_LINE = "Developed by NABAD Computer Solutions L.L.C."
CANON_AR_LINE = "تطوير نبض لحلول الكمبيوتر ذ.م.م."
CANON_AR_NAME = "نبض"

# Not Arabic words at all — only ever a botched transliteration of "NABAD".
# Matched at Arabic word boundaries, never as bare substrings: نباد is a
# substring of the everyday verbs نبادل ("we exchange") and نبادر ("we
# initiate"), and flagging those would be a false positive on ordinary copy.
BANNED_NAME_FORMS = ["ناباد", "نباد", "نابد", "ناباض", "نابااد", "نااباد", "نبظ", "نبأد"]
AR_LETTER = "؀-ۿ"
BANNED_FORM_RE = re.compile(
    "|".join(f"(?<![{AR_LETTER}]){re.escape(v)}(?![{AR_LETTER}])" for v in BANNED_NAME_FORMS)
)
# "…<name> لحلول الكمبيوتر" — the Arabic credit line, whatever name it carries.
AR_CREDIT_RE = re.compile(rf"([{AR_LETTER}]+)\s+لحلول\s+الكمبيوتر")

# The registry: the four files that ARE the ban list, and so must be able to
# carry the wrong forms as raw data — the canon's table, this script's list,
# the guard hook's list and test fixtures, and the changelog entry recording
# the fix. They are skipped wholesale. Every OTHER file may still mention a
# wrong form, but only as a backtick-quoted code span, and only if it
# references the canon — i.e. only doctrine that teaches the rule.
BAN_LIST_OWNERS = {
    ATTRIB_CANON_REL,
    "scripts/validate-fleet.sh",
    "hooks/guard-attribution-canon.sh",
    "CHANGELOG.md",
}

attrib_text = require_file(repo_root / ATTRIB_CANON_REL, CHECK14)
if attrib_text is not None:
    for needle, label in ((CANON_EN_LINE, "English credit line"),
                          (CANON_AR_LINE, "Arabic credit line")):
        if needle not in attrib_text:
            fail(CHECK14, f"{ATTRIB_CANON_REL}: canonical {label} missing or altered — "
                          f"expected the verbatim string `{needle}`")

SCANNED_SUFFIXES = {".md", ".sh", ".json", ".html", ".txt", ".yml", ".yaml", ""}
SKIP_DIRS = {".git", "node_modules", "dist", "build", ".next"}

attribution_files = 0
for f in sorted(repo_root.rglob("*")):
    if not f.is_file():
        continue
    if any(seg in SKIP_DIRS for seg in f.relative_to(repo_root).parts):
        continue
    if f.suffix.lower() not in SCANNED_SUFFIXES:
        continue
    try:
        text = read(f)
    except (UnicodeDecodeError, OSError):
        continue
    rel = f.relative_to(repo_root).as_posix()

    # The registry files ARE the ban list — they carry the wrong forms as data
    # (a Python list, a regex, hook test fixtures, the record of the fix), so
    # neither rule can apply to them without the gate eating itself. Every
    # other file in the repo is scanned.
    if rel in BAN_LIST_OWNERS:
        continue

    # (b) Every Arabic credit line names نبض — the generic rule.
    for m in AR_CREDIT_RE.finditer(text):
        attribution_files += 1
        name = m.group(1)
        if name != CANON_AR_NAME:
            fail(
                CHECK14,
                f"{rel}: Arabic credit line reads «{name} لحلول الكمبيوتر», but the "
                f"company's Arabic name is «{CANON_AR_NAME}» — copy the canonical "
                f"string `{CANON_AR_LINE}` ({ATTRIB_CANON_REL}); never transliterate "
                f"the Latin \"NABAD\" into Arabic letters",
            )

    # (c) Known-wrong forms: mention-only, and only where the rule is taught.
    for m in BANNED_FORM_RE.finditer(text):
        form = m.group(0)
        start, end = m.span()
        line_start = text.rfind("\n", 0, start) + 1
        line_end = text.find("\n", end)
        line = text[line_start:line_end if line_end != -1 else len(text)]
        quoted = f"`{form}`" in line
        teaches_rule = ATTRIB_CANON_REL in text
        if not quoted:
            fail(
                CHECK14,
                f"{rel}: contains «{form}» as running text — a transliteration of the "
                f"Latin \"NABAD\". The company's Arabic name is «{CANON_AR_NAME}»; "
                f"doctrine may only MENTION a wrong form inside backticks",
            )
        elif not teaches_rule:
            fail(
                CHECK14,
                f"{rel}: names the banned form `{form}` but does not reference "
                f"{ATTRIB_CANON_REL} — only files that teach the attribution rule "
                f"may name what it forbids",
            )

guard_canon_rel = "hooks/guard-attribution-canon.sh"
if not (repo_root / guard_canon_rel).exists():
    fail(CHECK14, f"{guard_canon_rel} does not exist — the authoring-time gate is doctrine, not decoration")
elif guard_canon_rel not in hook_scripts:
    fail(CHECK14, f"{guard_canon_rel} exists but hooks/hooks.json does not wire it — an unwired guard never runs")


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
    print(f"  3. Model-tier tally       — {fable_count} fable / {opus_count} opus / {sonnet_count} sonnet matches .saeed/models.md")
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
    print(f" 10. Cross-reference res.   — {len(crossref_files)} files scanned, every")
    print(f"                              skills/<name>/SKILL.md reference resolves;")
    print(f"                              state.json skills roster matches skills/*/ both ways")
    print(f" 11. Canon reference form   — {len(doctrine_files)} doctrine files carry no bare")
    print(f"                              `skills/<name>` and no line-anchored SKILL.md:N ref")
    print(f" 12. Version parity         — plugin.json {version_of_record} matches the CHANGELOG")
    print(f"                              heading, README badge, and state.json")
    print(f" 13. Capability-map owners  — docs/CAPABILITY-MAP.md exists; {capmap_refs} agent-owner")
    print(f"                              references all resolve to agents/*.md")
    print(f" 14. Attribution strings    — canon EN+AR intact; {attribution_files} Arabic credit")
    print(f"                              line(s) all name نبض; no transliterated form")
    print(f"                              outside the ban-list registry; guard hook wired")
    print("=" * 78)
    print("RESULT: PASS")
    print("=" * 78)
    sys.exit(0)
PYEOF
exit $?
