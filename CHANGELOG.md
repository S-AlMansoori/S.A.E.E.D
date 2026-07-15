# Changelog

All notable changes to SAEED are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions follow
semver (patch = fixes, minor = new agents/skills/commands, major = breaking).
The version of record is `version` in `.claude-plugin/plugin.json`.
*(Sections before 1.7.0 are backfilled from commit history and are coarser.)*

## 1.9.0 - 2026-07-15

### Changed
- **`/saeed:hire` rewritten as the A-to-Z operational lifecycle runbook** —
  five gated phases, each with named owners and an explicit exit line:
  **Phase 0 Intake** (project-root fixing, sentinel checks, *unconditional*
  disaster-recovery entry, existing-repo takeover assessment, BRD/spec-corpus
  ingestion before any feature code, staffing check), **Phase 1 Spec & design**
  (stories + compliance criteria, UX flows/IA before architecture,
  architecture + ADRs + security threat model, test strategy incl.
  non-functional targets and AI-feature evals), **Phase 2 Build**
  (waves/worktrees/ticket queue, RED-gate TDD, standing CI + docs + SRE
  readiness tasks, review/design/appsec gates, secrets response, sign-off only
  on `VERDICT: READY` independently confirmed, integration as a separate run),
  **Phase 3 Harden, verify & deliver** (conditional pentest with a real
  failure path, `/saeed:verify`, handover-ladder deployment with unauthorized
  deploys parked, and a checkable **DELIVERED** definition: READY verdict +
  signed criteria + no open blockers + docs + attribution), **Phase 4
  Improve** (default 3-pass session budget replacing "a sensible number",
  `/saeed:upgrade` cadence). A phase pointer is written to `.saeed/state.json`
  at every transition so crash-resume works; the pause protocol separates
  mid-lifecycle resume (`/saeed:hire`) from post-delivery loops
  (`saeed-loop.sh`, lethal-trifecta-scoped). All nine skills are wired in.
  Verified by a 4-auditor workflow plus 3 adversarial lenses (all findings
  fixed; the ops lens's two high findings — unanchored project root,
  unwritable resume pointer — drove the v2 tightening).
- Docs brought into lockstep (EN + AR): the hire lifecycle chain in
  `help.md` / CHEATSHEET, README "What this is" + flow diagram (intake, threat
  model, harden & verify, deliver stages), WHAT-IS "what it actually does".

### Fixed
- **`.saeed/` ledger reconciled with reality**: cycles 6-7 (v1.7.0, v1.8.0)
  ran via a cloud branch and never updated the ledger — `state.json` still
  said v1.6.0 / cycle 5 / 5 skills and lacked the `facilitated_by` field its
  own v1.8.0 attribution convention mandates. Reconstructed from git +
  CHANGELOG per the disaster-recovery rule; queue/retro now record the
  missing cycles. A version-parity check for `validate-fleet.sh` is queued
  (the stale-state class escaped the gate across two releases).
- Doc rot from the unpulled cycles: WHAT-IS-SAEED skills list (EN + AR) named
  only 4 of the 9 absorbed canons (hardcoded count dropped to stop the drift);
  `what-is-saeed.html` commands table was missing `/saeed:verify`;
  `instincts.md` was absent from the `.saeed/` folder tables (EN + AR).

## 1.8.0 - 2026-07-15

### Added
- **`skills/attribution`** — the signed-work convention: everything SAEED
  builds or facilitates carries the **NABAD Computer Solutions L.L.C.**
  credit. Canonical strings (EN + AR, full / short / facilitated forms, a
  machine-readable `facilitated_by` ledger field, a commit trailer), a
  placement matrix (README/docs footers, existing UI credit surfaces,
  `.saeed/` state files, commits), and restraint rules (once per surface,
  never claiming ownership of the client's code, operator/client
  prohibitions parked rather than fought).

### Changed
- Wired the convention through the lifecycle: `/saeed:hire` writes
  `facilitated_by` at `.saeed/` creation and credits deliverables;
  `/saeed:improve` and the continuous-improvement cycle audit attribution as
  a standing dimension; `the-boss` checks it in the Definition of Done;
  `technical-writer` places the doc credit; `frontend-engineer` /
  `ui-visual-designer` place the quiet UI credit where a credit surface
  exists.

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
