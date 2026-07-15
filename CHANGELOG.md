# Changelog

All notable changes to SAEED are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions follow
semver (patch = fixes, minor = new agents/skills/commands, major = breaking).
The version of record is `version` in `.claude-plugin/plugin.json`.
*(Sections before 1.7.0 are backfilled from commit history and are coarser.)*

## 1.7.0 - 2026-07-15

The ECC absorption cycle: audited [Everything Claude Code (ECC)](https://github.com/affaan-m/ECC)
and absorbed its engineering-practice canon, adapted to SAEED's doctrine.

### Added
- **Guardrail hooks** (`hooks/`) — the mechanical floor under "the team never
  weakens its own gates": `guard-git-bypass.sh` blocks `--no-verify` /
  `core.hooksPath` git-hook bypasses, `guard-config-protection.sh` blocks
  weakening existing lint/format configs (creation stays allowed), and
  `session-brief.sh` injects a `.saeed/` state snapshot at session start.
  All fail open, pure bash + python3 stdlib.
- **`skills/verification-protocol`** — the evidence canon: ordered executable
  gates (build → types → lint → tests → security → diff), the RED-gate TDD
  rule, the fixed Verification Report with a READY/NOT READY verdict,
  pass@k vs pass^k eval thresholds, and the anti-noise review doctrine.
- **`skills/context-discipline`** — the memory & attention canon: strategic
  compaction at phase boundaries, write-before-compact, confidence-scored
  instincts in `.saeed/instincts.md`, model routing with upgrade triggers,
  subagent context negotiation, and the tool-surface budget.
- **`skills/agentic-security`** — the defend-the-team canon: prompt-defense
  baseline, the lethal-trifecta rule for unattended runs, deny-rules and
  separate bot identity, plans/BRDs as untrusted input, and the secrets
  response protocol.
- **`/saeed:verify`** — runs the Verification Protocol end to end and returns
  the evidence-backed READY/NOT READY report.
- **CI** (`.github/workflows/validate.yml`) — runs `scripts/validate-fleet.sh`
  on every push/PR; hardened per the audited practices (read-only
  permissions, `persist-credentials: false`, SHA-pinned actions).
- **`validate-fleet.sh` checks 8–9** — hook-contract smoke tests (bypass
  payloads must block, benign ones must pass, the session brief must emit
  valid SessionStart JSON) and command/skill frontmatter integrity.
- `SECURITY.md`, this `CHANGELOG.md`, and plugin-manifest schema notes in
  `CONTRIBUTING.md`.

### Changed
- Ten agents wired to the new canons (one-line doctrine references):
  `the-boss`, `code-reviewer`, `qa-automation-engineer`, `test-architect`,
  `self-eval-critic`, `team-orchestrator`, `model-scout`,
  `security-architect`, `appsec-engineer`, `continuous-improvement-lead`.
- `skills/continuous-improvement` — `.saeed/instincts.md` added to the state
  inventory; gates now cite the Verification Protocol.

### Fixed
- `scripts/validate-fleet.sh` failed on any fresh clone (and would have
  failed CI) because it hard-required the gitignored `.saeed/state.json` and
  `.saeed/models.md`; those drift checks now run only when the files exist —
  present-but-stale still fails.

## 1.6.0 - 2026

### Added
- Self-Governance succession doctrine (`skills/self-governance`): decision
  rights, precedence and tie-breaking, autonomy levels (`.saeed/AUTONOMY`),
  operator-absent defaults (park under `## Awaiting operator`, never
  deadlock), post-convergence stewardship, disaster recovery, and the
  amendment process. The team runs without a human lead ([docs/SUCCESSION.md](docs/SUCCESSION.md)).
- Stewardship heartbeat runner `scripts/saeed-steward.sh`.

## 1.5.0 - 2026

### Added
- `macos-engineer` (roster to 54), fleet-wide certification rules, and the
  executable self-lint gate `scripts/validate-fleet.sh`.

## 1.4.0 - 2026

### Added
- Capability-first Handover Protocol (`skills/handover-protocol`): automate,
  drive, or hand off to Cowork before ever handing the user a manual chore.

### Changed
- Relicensed to the SAEED Non-Commercial License 1.0 (NABAD).

## 1.3.0 - 2026

### Added
- Roster expanded to 53 agents (incl. `hr-talent-lead`, `prompt-engineer`)
  and wired via reciprocal handoffs.
- Absorbed the Design Excellence canon (`skills/design-excellence`, with the
  `design-reviewer` gate) and the Orchestration Protocol
  (`skills/orchestration-protocol`, from the claude-sdlc-kit methodology).

## 1.0.0 - 2026

### Added
- Initial release: the Self-Advancing Elite Engineering Directorate —
  specialist subagent fleet, `/saeed:*` commands, the continuous-improvement
  loop with honest convergence, `scripts/saeed-loop.sh`, bilingual
  Arabic/English branding, and NABAD attribution.
