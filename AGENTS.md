# AGENTS.md — working on the SAEED repository

Instructions for any coding agent (or person) that edits **this repository**. Contribution rules
for humans are in [CONTRIBUTING.md](CONTRIBUTING.md); this file is the short, verified version.

## What this repo is

SAEED is a **Claude Code plugin** (plugin name `saeed`, marketplace name `saeed-marketplace`):
55 subagents, 7 slash commands, 19 skills and a set of guard hooks.
There is no application, no package manager, no dependencies and no build. The product is the
Markdown, JSON and shell in this tree. The repository is **public**: everything committed here is
published.

## Layout

| Path | What it is |
|---|---|
| `.claude-plugin/plugin.json` | Plugin manifest. Its `version` is the version of record. |
| `.claude-plugin/marketplace.json` | Marketplace manifest (one plugin, `source: "./"`). |
| `agents/<name>.md` | One subagent each (55 files): YAML frontmatter `name`, `description`, `model` (all required) and, on some agents, `tools`; then the system prompt. `name` must equal the file name. |
| `commands/<cmd>.md` | The 7 `/saeed:<cmd>` slash commands (frontmatter `description`). |
| `skills/<name>/SKILL.md` | The 19 skills ("canons"). Frontmatter `name` must equal the directory name; `description` is a single line. |
| `hooks/hooks.json` + `hooks/*.sh` | Hook wiring and 5 hook scripts (4 guards on `PreToolUse`, 1 `SessionStart` brief). |
| `scripts/validate-fleet.sh` | The consistency gate (bash wrapping an embedded python3 script). |
| `scripts/saeed-loop.sh`, `scripts/saeed-steward.sh` | Runners that call the `claude` CLI headlessly in a target repo. |
| `docs/` | User documentation in English and Arabic, including `what-is-saeed.html`. |
| `.github/workflows/validate.yml` | CI: runs the gate on pushes to `main` and on every pull request. |
| `README.md`, `CHANGELOG.md`, `CONTRIBUTING.md`, `SECURITY.md`, `LICENSE` | Public documentation and licence. |

`.saeed/` is per-project runtime state that the plugin creates in the repos it works on. It is
git-ignored here and normally absent.

## Commands (all verified; none needs a network)

Requirements: `bash` and `python3` (standard library only). Verified with bash 3.2.57 and
Python 3.9.6 and 3.12.16 on macOS; CI uses `ubuntu-latest`. Step-by-step run instructions,
including the offline ones, are in the "Run the checks" section of `README.md`.

```bash
# The gate. Must print "RESULT: PASS" and exit 0. Takes about 2 seconds.
./scripts/validate-fleet.sh

# Syntax check of every shell script.
for f in scripts/*.sh hooks/*.sh; do bash -n "$f" || echo "SYNTAX ERROR: $f"; done

# Optional, only if shellcheck is installed (clean at this level with 0.11.0).
shellcheck -S warning scripts/*.sh hooks/*.sh
```

There is no install step, no build, no dev server, no port, no database and no environment
variable to set. `CLAUDE_PLUGIN_ROOT` in `hooks/hooks.json` is supplied by Claude Code at run time.

**Do not run `scripts/saeed-loop.sh` or `scripts/saeed-steward.sh` as a check.** They start
`claude -p "/saeed:improve" --permission-mode acceptEdits` in the target directory, which edits
files unattended.

## What the gate checks

`scripts/validate-fleet.sh` runs 14 checks (the list with reasons is in the comment block at the
top of the script). Check 6 is advisory; the others fail the run. The ones you will trip most:

- **Check 1, agent count.** The number of `agents/*.md` files must match every place that states
  it: `README.md` (intro line, badge, roster heading), both manifests, `docs/WHAT-IS-SAEED.md`,
  `docs/CHEATSHEET.md` and `docs/what-is-saeed.html`, in English and Arabic (Arabic numerals too).
- **Check 3, model tiers.** The `model:` tally across agents must match the "Model mix" legend in
  `docs/what-is-saeed.html`.
- **Check 5, handoffs.** Every backticked agent name in a `## Handoffs` section must be a real agent.
- **Check 8, hook contract.** Every script named in `hooks/hooks.json` must exist. The guards are
  run against real payloads: a bypass attempt must exit 2, a harmless one must exit 0, and the
  session brief must print valid JSON.
- **Checks 10 and 11, skill references.** Write references in full as `skills/<name>/SKILL.md`,
  pointing at a skill that exists. No bare `skills/<name>` in backticks and no line anchors
  (`SKILL.md:12`) in `agents/`, `commands/`, `skills/` or `hooks/`.
- **Check 12, version parity.** See "Versioning" below.
- **Check 13, capability map.** Every owner named in `docs/CAPABILITY-MAP.md` must be a real agent.
- **Check 14, attribution.** The company's Arabic name must be copied from
  `skills/attribution/SKILL.md`, never re-typed or transliterated. This check scans every `.md`,
  `.sh`, `.json`, `.html`, `.txt` and `.yml` file in the repo, including this one.

## Versioning

- The version of record is `version` in `.claude-plugin/plugin.json`.
- The newest `## <version> - <date>` heading in `CHANGELOG.md` and the version badge in
  `README.md` (both the `alt` text and the image URL) must equal it, or Check 12 fails.
- Semver as stated at the top of `CHANGELOG.md`: patch for fixes, minor for new agents, skills or
  commands, major for breaking changes.
- A change to the shipped plugin (`agents/`, `commands/`, `skills/`, `hooks/`, `scripts/`,
  manifests) gets a version bump and a `CHANGELOG.md` section in the same change. Documentation
  only: no bump; list it under `## Unreleased` at the top of `CHANGELOG.md`.
- A bump edits four places: `plugin.json`, the new `CHANGELOG.md` heading, the README badge and
  the "Current version" line in the README's "Versioning" section.
- One-line check: `./scripts/validate-fleet.sh` (Check 12).
- Releases: no tags, no GitHub Releases, no build. The plugin installs from `main`, so a version is
  released when its commit reaches `main`. Do not create `v*` tags.
- Current version: 1.17.0 (released 2026-09-11, commit `e8c520a`). 1.18.0 and 1.19.0 exist only on
  unmerged branches (pull requests #4 and #5); do not reuse or skip past those numbers on `main`
  without the owner.

## Rules that are easy to break

- Do not add an `agents` or `hooks` key to `.claude-plugin/plugin.json`; both are discovered by
  convention. `commands` or `skills`, if declared, must be arrays. `version` is required.
- Hooks are pure bash plus python3 standard library, with no installs and no network. They fail
  open (exit 0) on input they cannot parse and block with exit 2 and a reason on stderr. Every
  blocking behaviour needs a smoke test in Check 8 of the gate.
- Never weaken a guard hook or the gate to make a change pass.
- Adding or removing an agent means updating the roster table in `README.md` and every count
  listed under Check 1.
- User-facing text is bilingual (English and Arabic). Keep both sides in step.
- Write nothing personal, no machine paths, no credentials and nothing from private projects.

## Things that will surprise you

- On a fresh clone the gate prints six `NOTE:` lines saying the `.saeed/` checks were skipped.
  That is expected. The summary printed under `PASS` still mentions `.saeed/state.json`,
  `.saeed/models.md` and the ledgers even though those parts did not run; trust the `NOTE:` lines.
- The gate resolves the repo from its own location, so it can be run from any directory.
- The gate creates temporary directories under the system temp folder and removes them. It leaves
  the working tree unchanged.
- `docs/what-is-saeed.html` loads four font families from Google Fonts. Offline it falls back to
  system fonts and stays readable. The badges at the top of `README.md` are remote images too.
- Using the plugin itself needs Claude Code and its model access. That part cannot run offline;
  the gate and the syntax checks can.
