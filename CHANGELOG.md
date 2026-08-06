# Changelog

All notable changes to SAEED are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions follow
semver (patch = fixes, minor = new agents/skills/commands, major = breaking).
The version of record is `version` in `.claude-plugin/plugin.json`.
*(Sections before 1.7.0 are backfilled from commit history and are coarser.)*

## 1.11.0 - 2026-08-06

Cycle 10 — absorb the operator's four-part audit checklist (UX & Trust [Kev + Katia UX],
Security [Michael Ly + Casco], Performance [Hayden Smith], AI Automation Readiness
[Ahmed Alassafi]), folded into a `/saeed:upgrade` run the operator invoked mid-cycle.
Coverage audit first, per the house idiom: the Performance section was already absorbed
rule-for-rule (`skills/performance-discipline`, same source), and the Security section's
first ten items are the existing gate in the operator's own order — so the cycle extends
three canons rather than adding one. Source verbatim in `.saeed/tasks/cycle-10/sources/`.

### Changed
- `skills/app-hardening` — the pre-ship gate grows from ten to **seventeen** points, numbered
  as the operator wrote them: IDOR/object-level authorization (11), real logout (12), file
  upload safety (13), payment-webhook signature verification (14), deny-by-default access
  control beyond tables (15), centralized access checks (16), record ownership at the
  data-model level (17). The eight external references to the gate (5 agents, 3 commands)
  and the doc surfaces (README, CHEATSHEET EN+AR, WHAT-IS EN+AR) are **de-numbered** to
  "pre-ship gate" — the stale-count defect class (cycles 1, 3, 9) applied preventively, so
  the count now lives in exactly one home.
- `skills/design-excellence` — new **"Trust & perceived responsiveness"** law set: no dark
  patterns, instant acknowledgment with background processing, consistent onboarding
  controls, proportional success states ("no action vanishes into the void"), failures as
  designed surfaces. Skeleton loaders and friendly errors were already law.
- `skills/spec-quality` — new **"The AI-automation readiness map"**: every workflow task
  classified human-led / human-assisted / fully autonomous, plus one named knowledge-base
  source of truth for all AI features; binds at the requirements layer, N/A-capable.

### Evidence
- Light eval per `skills/canon-craft`: a **live fresh-agent trigger smoke** (exceeds
  cycle-9's traced-smoke precedent) — a clean-context reviewer found all three planted
  defects citing the new gate items 11/12/14 and returned BLOCK. Coherence ran inline by
  the coordinator after two independent-critic attempts died to the session usage limit;
  the independent re-run is queued debt. Evidence: `.saeed/tasks/cycle-10/eval-evidence.md`.
- Upgrade steps 2–5 concluded inline under the usage limit: NO-HIRE (no exercised gap,
  cycle-5 precedent), no optimizer/roster changes, MS-1 (fable re-tier) surfaced to the
  operator for decision.

## 1.10.0 - 2026-07-25

The absorption cycle: seven operator-named external skill sources (two Supabase skills, the
`/security-review` change-level review, `/engineering:code-review`, the `securitymaxxing`
10-point checklist, Hayden Smith's 5 slow-app reasons, mikesol's `repository-housekeeping`) plus a
verified ten-source research shortlist (Anthropic's `skill-creator` + authoring best practices +
the Agent Skills open standard, Obra's `superpowers`, nizos's `tdd-guard`/Probity, GitHub Spec Kit,
Anthropic's `mcp-builder`, EveryInc's compound-engineering plugin, the 2026-06 frontend-design
revision, `webapp-testing`, and `doc-coauthoring`) — see
`.saeed/tasks/cycle-9/skill-research.md` — distilled into eight new house canons and seven
additive extensions to existing ones, per the house absorption idiom (`skills/design-excellence`,
`skills/agentic-security`).

### Added
- **`skills/supabase-craft`** — schema/migrations, Auth/JWT/RLS and `@supabase/ssr` sessions, Edge
  Functions, Realtime, Storage, Vectors, Cron/Queues, client patterns with service-role isolation,
  CLI/MCP, security advisors, extensions, and Postgres query/schema/config performance.
- **`skills/app-hardening`** — the 10-point pre-ship gate (rate limiting, server-side secrets, RLS
  everywhere, `.env` hygiene, input validation, explicit permissions, auth on every protected
  route, generic errors, locked-down admin surfaces, attack-visible logging), disjoint from
  `skills/agentic-security` (product vs team).
- **`skills/performance-discipline`** — never ship uncompressed responses, never write rows one at
  a time, name the slowest dependency before optimizing, update UI optimistically with
  reconciliation, serve static frontends statically.
- **`skills/repo-housekeeping`** — git hygiene and untracked-file triage (commit-over-delete with
  a secrets exception), two-copies/upstream sync discipline (the operator's "check drift"
  instinct, now doctrine), recent-session knowledge distillation, organizational and
  orientation-file audits, and close-out reporting. Tends the *workspace*; the improvement loop
  tends the *product*. Its entrypoint is the steward branch of `/saeed:improve` — no new command
  and no script change — and its gate is `the-boss`'s Workspace-clean DoD. The canon and its
  wiring ship here; the first executed housekeeping pass is deliberately its own first outing.
- **`skills/engineering-method`** — the TDD Iron Law with its rationalization counters, four-phase
  systematic debugging, the brainstorm HARD-GATE before implementation, the zero-context plan law,
  subagent-controller mechanics, TDD adjudication rules (Probity), and the task-size (S/M/L)
  applicability ladder — defined exactly once, here, and referenced by every other canon and gate
  that scopes itself by task size. The ladder classifies *code changes*; work that ships no code
  answers to its own gates. Ships with a scoped, **opt-in** `hooks/guard-tdd-mode.sh` gated on a
  `.saeed/TDD` sentinel (`off`/`advisory`/`enforce`) as its mechanical floor — a repo with no
  sentinel is a no-op, and the hook blocks the shell bypass channels (`echo`/`printf`/`sed`/
  `awk`/`perl` redirects) as well as sentinel tampering.
- **`skills/canon-craft`** — the eval-driven authoring loop, description-trigger optimization,
  spec conformance (metadata/body/line budgets, one-level references), degrees-of-freedom
  calibration, and grounding-in-real-execution-traces discipline that now governs `/saeed:upgrade`
  and every canon authored from this cycle forward. The eight canons below were held to its
  mechanical floor (F1–F10) plus a light eval — a coherence pass and one trigger smoke each —
  with that scoping decision and its cost written into the canon itself. Agent files, commands,
  and hooks are deliberately out of its scope, and a retro-audit of the nine pre-existing canons
  is queued to the next cycle, not done here.
- **`skills/spec-quality`** — the ten-category ambiguity taxonomy, the bounded five-question
  clarification budget with informed-default Assumptions, answer integration, checklists as unit
  tests for requirements, and the read-only pre-implementation analysis gate with its
  requirements-to-tasks coverage table. Sits upstream of `skills/orchestration-protocol`.
- **`skills/mcp-craft`** — quality measured by LLM task success (a shipped 10-question agentic
  eval), API-coverage-over-workflow tool design, `{service}_{action}_{resource}` naming,
  pagination/truncation contracts, dual JSON/Markdown responses, and MCP-specific security
  hardening (token-audience validation, DNS-rebinding protection, Origin validation, loopback
  binding).
- **`/saeed:verify` security depth** — auto-escalates (or is invoked explicitly as
  `/saeed:verify security`) on diffs touching auth, input handling, secrets, the network boundary,
  new dependencies, or admin/debug surfaces: a severity-ranked findings report over the diff and
  its blast radius, ending in an explicit pass/block verdict.
- **`scripts/validate-fleet.sh` Checks 10 and 11** — two new hard checks, added mid-cycle beyond
  the planned scope because this cycle produced two live proofs the existing checks could not see.
  **Check 10 (cross-reference resolution)** resolves every `skills/<name>/SKILL.md` reference
  found under `agents/`, `commands/`, `skills/`, `hooks/`, `docs/`, or `README.md` against the
  filesystem, and asserts `.saeed/state.json`'s `skills` array against the real `skills/*/`
  directories in both directions. It closes a hole Checks 5 and 9 structurally cannot see: this
  cycle wired 28 references to a canon that had never been written, across 24 files, and the
  validator stayed green the whole time — Check 9 only enumerates directories that exist, and
  Check 5 only resolves backticked tokens inside a `## Handoffs` section.
  **Check 11 (canon reference form)** fails any bare backticked `` `skills/<name>` `` without
  `/SKILL.md`, and any line-anchored `SKILL.md:<digits>` cross-reference, on a doctrine surface
  (`skills/`, `agents/`, `commands/`, `hooks/`). Check 10 matches only well-formed references, so
  a typo'd canon name or a line anchor pointing at the wrong rule shipped green — which is exactly
  where this cycle's last two blocking defects hid. The fenced-code exclusion is scoped to
  `skills/canon-craft/SKILL.md` alone, the one canon that must be able to illustrate the form it
  forbids. Exit status is now "all hard checks (1–5, 7–11) passed".

### Changed (additive extensions — prior doctrine unchanged)
- **`skills/continuous-improvement`** — the codify step (schema'd learning docs filed to
  `.saeed/solutions/`), 5-dimension overlap scoring + staleness refresh, grounding validation, the
  `.saeed/CONCEPTS.md` vocabulary rule, the feed-forward mandate, and the one-pipeline knowledge
  routing tree (instincts vs the solutions library vs housekeeping distillation).
- **`skills/orchestration-protocol`** — Superpowers' worktree/parallel-dispatch/executing-plans
  deltas.
- **`skills/verification-protocol`** — E2E browser-evidence verification (server-lifecycle
  harness, headless Chromium, pre-navigation console-log capture, modernized web-first
  assertions), the bilingual doc cold-reader gate (AR and EN gated separately), and one pointer
  line escalating gate 5 to the new security depth.
- **`skills/self-governance`** — a constitution-governance subsection (a semver-versioned
  constitution artifact; violations auto-CRITICAL).
- **`skills/design-excellence`** — the 2026-06 delta: the named generic-AI-look blocklist (with
  hexes), the plan-then-critique convergence self-check, the one-signature-element token slot, and
  the CSS selector-specificity warning — including the corrective note that SAEED's own
  navy/gold-minimalist register must pass the same reflex check.
- **`skills/agentic-security`** — one line naming the TDD-mode guardrail hook in "Mechanical
  rails".
- **`skills/context-discipline`** — one line: the black-box test-infra rule.
- **`agents/code-reviewer.md`** — absorbs `/engineering:code-review`'s four check classes (N+1,
  injection, missing edge cases, error-handling gaps) as standing review lenses; adds
  `skills/supabase-craft/SKILL.md`, `skills/app-hardening/SKILL.md`, and
  `skills/performance-discipline/SKILL.md` as review lenses; carries
  `skills/engineering-method/SKILL.md`'s validator-conduct rules (re-derive judgment fresh, name
  the rationalization, treat an explicit operator override as authoritative) and an S/M/L
  tier sanity-check on every diff; and gains a reciprocal `query-optimization-engineer` handoff —
  N+1 is flag-and-route, never a transfer of ownership.
- **`/saeed:hire`, `/saeed:improve`, `/saeed:upgrade`** — the lifecycle entrypoints reference the
  new canons where sibling canons already appear: spec-quality and performance NFR targets at the
  spec phase, engineering-method's S/M/L tier and the Supabase/hardening/review gates at the build
  phase, app-hardening and performance-discipline in `/saeed:improve`'s audit dimensions plus the
  codify step and the housekeeping pass on its steward branch, and canon-craft in `/saeed:upgrade`
  wherever skills are authored.
- **Docs and manifests, EN + AR** — README absorbed-canon bullets, `docs/CHEATSHEET.md` skills
  lists (English and the Arabic mirror), `docs/WHAT-IS-SAEED.md` prose (English and Arabic), and
  the `plugin.json` / `marketplace.json` descriptions and keywords all name the new canons. No
  skills count is stated anywhere, in either script — counts were removed in 1.9.0 precisely
  because they drift. `docs/what-is-saeed.html` is byte-identical: no command was added.
- Class-wide wiring per the propagation invariant (SU-17): every new canon is applied by a named
  agent class or delegated to a named gate, and every deliberate exclusion is written down — see
  each canon's Wiring section, which is the shipped record of truth.

### Credits
Distilled from (never vendored — "never let a missing plugin lower the bar"): the operator-named
Supabase, `/security-review`, `/engineering:code-review`, `securitymaxxing`, and
`repository-housekeeping` (mikesol/cc-disco) skills; Anthropic's `skill-creator` and its authoring
best practices; the Agent Skills open standard (agentskills.io); Obra's `superpowers`; nizos's
`tdd-guard`/Probity; GitHub Spec Kit; Anthropic's `mcp-builder`; EveryInc's compound-engineering
plugin; the 2026-06 frontend-design revision; and `webapp-testing` / `doc-coauthoring` — per the
research decision document `.saeed/tasks/cycle-9/skill-research.md`.

## 1.9.1 - 2026-07-15

### Changed
- **Attribution simplified to a single credit line** (operator instruction):
  every visible credit surface now shows exactly
  `Developed by NABAD Computer Solutions L.L.C.` (Arabic mirror
  `تطوير نبض لحلول الكمبيوتر ذ.م.م.` on bilingual surfaces; commit trailer
  `Developed-By: NABAD Computer Solutions L.L.C.`). The full / short /
  facilitated variants are retired; existing older variants get updated to
  the canonical line when touched. The machine-readable
  `facilitated_by` ledger key is unchanged for compatibility. Updated
  `skills/attribution`, `/saeed:hire`'s state-file header, and the
  agent wiring (`technical-writer`, `frontend-engineer`,
  `ui-visual-designer`).

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
