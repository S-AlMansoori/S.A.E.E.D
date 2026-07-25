---
name: continuous-improvement
description: The shared protocol and state-file convention for SAEED's autonomous improvement loop. Consult when running or reasoning about /saeed:improve, the .saeed/ state directory, convergence, or how the team keeps working on a project without supervision.
---

# SAEED Continuous-Improvement Protocol

This skill defines how the team works on a handed-over project continuously and how it knows when to stop. All agents share this convention.

## The `.saeed/` state directory

Every managed repo gets a `.saeed/` directory:

- `queue.md` — the prioritized improvement backlog. Each item: `id | title | owner-agent | acceptance-criteria | status`. Status is one of `TODO / IN_PROGRESS / IN_REVIEW / DONE / REJECTED / WONTFIX`. May also carry an `## Awaiting operator` section — proposals parked for an absent operator per the Self-Governance protocol, never blocking the pass.
- `state.json` — machine-readable ledger of items, cycle count, and last-updated timestamp.
- `retro.md` — append-only log of retrospectives, agent-optimization notes, and roster/model changes.
- `models.md` — current model tiering (which agent runs on which model) with change history.
- `instincts.md` — confidence-scored, atomic learnings (one trigger + one action each) per `skills/context-discipline/SKILL.md`; high-confidence instincts are candidates for promotion into the plugin via `/saeed:upgrade`.
- `CONVERGED` — sentinel file. Present ONLY when the `continuous-improvement-lead` has decided, with evidence, that no improvement above the value threshold remains. Its contents explain why.
- `STOP` — sentinel file. Present when the human has halted the loop. Overrides everything.
- `AUTONOMY` — sentinel holding the autonomy level (first non-blank, non-`#` line). Absent or `supervised`: self-modification is proposal-only and parks for the operator. `autonomous`: it may land unattended, fully gated and logged. Defined in `skills/self-governance/SKILL.md`.
- `solutions/` — the compounding knowledge library: one schema'd learning doc per solved problem, filed as `solutions/<category>/<slug>.md` with YAML frontmatter, written by the codify step at cycle close (see "Compounding: the codify step"). Searchable, and read as grounding before any new plan.
- `CONCEPTS.md` — the project's shared domain vocabulary: entities, named processes, and status concepts with project-specific meaning. A glossary, never a file/class catalogue. Accretes from codify runs; direct edits are fine.

## The cycle (one iteration)

1. **Stop check** — if `.saeed/STOP` exists, halt. If `.saeed/CONVERGED` exists, halt unless overridden.
2. **Audit & prioritize** — `continuous-improvement-lead` audits across correctness, security, performance, accessibility, i18n/RTL, **design excellence (anti-AI-slop craft, per `skills/design-excellence/SKILL.md`)**, tests, docs, DX, cost, and **attribution (the NABAD credit, per `skills/attribution/SKILL.md`)**; writes the top items to `queue.md` with measurable criteria.
3. **Assign** — `the-boss` assigns each item to the owning specialist and holds the Definition of Done.
4. **Implement** — specialists do the work on disjoint files where parallelized, in worktree-isolated waves per the Orchestration Protocol (`skills/orchestration-protocol/SKILL.md`).
5. **Gate** — `code-reviewer` + `qa-automation-engineer` must pass before an item is accepted; user-facing items must also pass the `design-reviewer` (design-excellence) gate. Gates run per the Verification Protocol (`skills/verification-protocol/SKILL.md`): ordered, executable, ending in a READY/NOT READY report.
6. **Verify** — `self-eval-critic` independently confirms gains and catches regressions; writes a retro.
7. **Record** — `the-boss` updates `state.json` and produces a standup.
8. **Self-upgrade (periodic)** — every few cycles, run the `/saeed:upgrade` flow (`model-scout`, `agent-optimizer`, `roster-maintainer`).
9. **Codify (mandatory, at every cycle close)** — unlike step 8, this one is not periodic: before the loop starts over, `continuous-improvement-lead` harvests the cycle's learnings into `.saeed/solutions/` and routes the rest per "Compounding: the codify step". A cycle whose knowledge was never harvested is not closed.

## Definition of Done

An item is DONE only when: acceptance criteria met AND reviewed AND tested AND documented AND independently verified. No self-attestation without evidence. For user-facing items, "reviewed" also means the `design-reviewer` gate approved it against the Design Excellence canon (no absolute-ban violations, all states present, RTL correct).

## Design excellence (baked-in house standard)

SAEED has absorbed a body of elite frontend-design skills into `skills/design-excellence/SKILL.md`. Every UI-touching agent applies that canon automatically — no user has to ask — and invokes the deeper `impeccable` / `gpt-taste` / `high-end-visual-design` / `design-taste-frontend` / `emil-design-eng` skills when installed. `design-reviewer` is the gate that enforces it, the design counterpart to `code-reviewer`.

## Parallel execution & integration (baked-in delivery discipline)

SAEED has absorbed the claude-sdlc-kit methodology into `skills/orchestration-protocol/SKILL.md`. Parallel work runs in worktree-isolated **waves** off a shared ticket queue with self-contained targeted briefs and four-state status reports; gates are executable and run by `the-boss`; **branch integration is always a separate, gated run** (owned by `devops-platform-engineer`) with atomic conventional commits; heavy QA uses the adversarial parallel-browser recipe; and BRD corpora are turned into a provenance-tagged, agent-searchable knowledge base before any feature code.

## Convergence (the honest stop)

The loop is designed to terminate. When a full audit surfaces nothing above the value threshold (i.e., remaining ideas are churn, speculative rewrites, or cosmetic), the `continuous-improvement-lead` writes `.saeed/CONVERGED` with the evidence — and with concrete reopen triggers — rather than manufacturing busywork. Convergence is success.

## Stewardship (after convergence)

Converged is not dead. A converged project stays alive through lightweight **steward passes** (`scripts/saeed-steward.sh`, meant for cron, or a headless `/saeed:improve`): re-run the executable gates, check the written reopen triggers, sweep model/dependency currency periodically, append a one-line heartbeat to `retro.md`, and reopen only when a trigger fires or a gate goes red. Full semantics, plus decision rights, precedence/tie-breaking, operator-absent defaults, and the disaster-recovery runbook, live in `skills/self-governance/SKILL.md` — the loop never deadlocks waiting for an absent operator.

## Human overrides

- Drop a `.saeed/STOP` file (or run `/saeed:stop`) to halt immediately, mid-cycle.
- Delete `CONVERGED` and run `/saeed:improve` to resume with new goals.
- Self-modification of the team (roster/model changes) requires human approval unless `.saeed/AUTONOMY` is set to `autonomous` (see `skills/self-governance/SKILL.md`); in supervised mode with no operator present, proposals park under `## Awaiting operator` instead of blocking.

## Safety rails

- The team never disables its own review/test/security gates to make progress.
- Roster and model changes are reversible and logged.
- Destructive actions (deleting agents referenced by open items, destructive migrations) are blocked.

## Compounding: the codify step (absorbed canon)

SAEED has absorbed the compound-engineering doctrine: **each unit of work must make the next one cheaper.** A debugged root cause, a dead end, a convention argued to a conclusion — left in a transcript, all of it evaporates and gets re-earned at full price next cycle. Codify converts it into grounded, searchable, reusable knowledge that the next plan is *required* to read. Invoke the deeper `compound-engineering` plugin (EveryInc — `/ce-compound`, `/ce-compound-refresh`) for full depth when installed. Never let a missing plugin lower the bar.

### The codify step is mandatory

At every cycle close (step 9), after `the-boss` records the standup, the cycle's learnings are written into `.saeed/solutions/`:

- **One learning per doc, one doc per run.** Batching several learnings through one pass produces drafting-context leakage ("Learning 3") and cross-references stitched between drafts instead of grounded against the tree.
- **Two tracks, different shapes.** *Bug track*: Problem · Symptoms · What Didn't Work · Solution · Why This Works · Prevention. *Knowledge track*: Context · Guidance · Why This Matters · When to Apply · Examples. The track follows the `problem_type`; never force bug-track fields onto durable guidance or vice versa.
- **Schema'd YAML frontmatter, always** — `title`, `category`, `problem_type`, `component`, `tags`, `date`, plus `root_cause` / `resolution_type` / `severity` (bug track) or `applies_when` (knowledge track), and `last_updated` whenever an existing doc is refreshed. Frontmatter must be parser-safe: quote any value containing ` #` (silent comment truncation) or `: ` (silent mapping confusion).
- **"What Didn't Work" is not optional on the bug track.** The failed attempts are the most expensive part of the investigation and the first thing lost.
- **Non-trivial and verified only.** A typo fix compounds nothing; an unverified fix compounds a lie. The strongest candidates are the bugs that survived a first fix attempt — the same trigger that opens systematic debugging in `skills/engineering-method/SKILL.md`.
- **Record the null result.** "Codify: nothing above the bar this cycle" is a legitimate outcome; a silent skip is indistinguishable from a forgotten step.

### Update, don't duplicate: 5-dimension overlap scoring

Before creating anything, search the library and score overlap with the existing corpus across five dimensions: **problem statement · root cause · solution approach · referenced files · prevention rules.**

| Overlap | Dimensions matched | Action |
|---|---|---|
| **High** | 4–5 | **Update the existing doc** with the fresher context; keep its path, title, and frontmatter structure, add `last_updated`. Do not create the second doc. |
| **Moderate** | 2–3 | Create the new doc, and flag the pair for a consolidation review. |
| **Low / none** | 0–1 | Create the new doc. |

Two docs describing the same problem drift apart, and then both are half-trusted. This scoring governs **every** store in the routing tree below, not just the solutions library: a harvest pass checks the other layers before creating anything.

**Selective staleness refresh.** A new learning is evidence about old ones. Refresh when the new fix contradicts or supersedes documented guidance, when a refactor/migration/rename/upgrade invalidated older references, when a pattern doc now reads too broad, or when the overlap search surfaced high-confidence candidates. Do **not** refresh when nothing related was found, when the related docs are still consistent, or when the review would need a broad historical sweep on weak evidence. Refresh is narrow-scoped and evidence-driven — never a full-corpus audit, and never a prerequisite for capturing the new learning.

### Grounding validation — before knowledge becomes permanent

Every future planner will trust these docs, so an ungrounded claim compounds too:

- **Cite `file:line` for behaviour claims.** Read the defining line at the current tree before asserting how code behaves (enum values, limits, defaults, state semantics). A claim that cannot be verified against the tree is softened or attributed ("per this session's conclusion"), never stated as fact.
- **Cite PR numbers, not commit SHAs.** Rebase and squash merges rewrite SHAs. A "fixed in X" claim requires the fix to be reachable from the current tree; otherwise phrase it as pending.
- **Adjudicate flags, don't auto-fix them.** A doc may legitimately cite a path deleted by the very fix it documents. Each flag is fixed, annotated as historical, or confirmed intentional — with the call written down.
- `self-eval-critic` holds this gate, to the evidence standard in `skills/verification-protocol/SKILL.md`.

### `.saeed/CONCEPTS.md` — vocabulary, not documentation

- **Domain entities, named processes, and status concepts only — never a file path, class name, function signature, or current config value.** Those live in code and in orientation files; a class name dressed up as an entity is refused.
- On bilingual projects, define the term once with both its Arabic and English forms, so the two surfaces name the same concept.
- Entries accrete as a side effect of documenting a real learning — seed the area that learning touched, hold borderline terms for a later run. Never bootstrap a repo-wide glossary from imagination.
- Touching an entry means refreshing its **coherence neighborhood** (its cluster siblings and cross-referenced terms) on evidence already in hand; anything needing fresh investigation is flagged, not guessed. Never a full-file audit.
- Scanned and nothing qualified? Say so. Silent skips are unauditable.

### Feed-forward is a mandate, not an option

Capture is worthless if nothing reads it back. Before structuring any new plan, spec, or architecture, planners — `product-engineer`, `principal-architect`, and anyone brainstorming an approach — **search `.saeed/solutions/` and the ≥0.7-confidence entries in `.saeed/instincts.md` first**, and state in the plan what was found (or that the search came back empty). An audit that re-derives a documented root cause is a failed audit; a `queue.md` item that re-solves a documented problem cites the doc instead. That return arrow is the whole point of codifying.

Discoverability follows: a managed repo's orientation files should mention that the solutions library exists, roughly how it is organized, and when it is relevant — described, not commanded ("relevant when implementing or debugging in documented areas", not "always search first"). Those edits route through `skills/repo-housekeeping/SKILL.md`.

### Artifact paths, not prose, across the subagent seam

A subagent asked to return a long body inline sometimes returns an executive summary instead, and the original prose is then unrecoverable. So: **a dispatched subagent writes its full output to a scratch artifact and returns only that path; the orchestrator reads it back.** An inline return is the fallback for when the write did not succeed. The rule runs the other way too — hand subagents reference *paths*, not pasted file contents: discovery is cheap, reading is expensive, and the subagent is closer to the task than the dispatcher is. This is the same context hygiene `skills/context-discipline/SKILL.md` applies to the main thread.

### One pipeline, three layers, one routing tree

Knowledge capture is a routing tree over a single stream — not three stores of equal rank competing for the same finding.

**One capture stream.** Experience lands where it always has: `.saeed/retro.md`, append-only, in the moment. Nothing new writes anywhere else while the work is happening.

**Two harvest passes, different cadences, the same tree.** The codify step (mandatory, every cycle close, product-focused) and the housekeeping pass's recent-session review (periodic, workspace-focused — `skills/repo-housekeeping/SKILL.md`). Both route findings; neither owns a private store.

**One routing tree.** For each finding:

| Shape of the finding | Where it goes |
|---|---|
| An atomic trigger → action behaviour | an instinct in `.saeed/instincts.md`, confidence-scored, in the format defined by `skills/context-discipline/SKILL.md` |
| An explanation — a debugged root cause, how a system works, a gotcha | a schema'd learning doc in `.saeed/solutions/` |
| A vocabulary term (a domain entity) | `.saeed/CONCEPTS.md` |
| A repo-orientation fact | the repo's orientation files (CLAUDE.md / README), per `skills/repo-housekeeping/SKILL.md` |
| Doctrine proven across projects | promoted into the plugin via `/saeed:upgrade` — self-modification, bound by `.saeed/AUTONOMY` (`skills/self-governance/SKILL.md`). Solutions docs count as promotion evidence alongside instincts. |

The overlap scoring above governs every row: check the other layers before creating anything. The same fact living in two stores is drift with extra steps.

### API-surface facts: the installed skill is ground truth

Anthropic API reference material churns faster than doctrine does, so it is deliberately **not** absorbed into any SAEED canon. RAG/LLM agents and `/saeed:upgrade` treat the **installed** `claude-api` skill as ground truth for API-surface facts (models, parameters, limits, headers) — never a distilled copy, never memory — and refresh it as part of the session-start two-copies drift check in `skills/repo-housekeeping/SKILL.md`. A stale distillation of a fast-moving reference is worse than no distillation.

### Deliberately not absorbed

The source plugin's reviewer personas and its plan/work/worktree loop mechanics stay out: change-level review belongs to `agents/code-reviewer.md` and the `/saeed:verify` security depth, and execution mechanics belong to `skills/orchestration-protocol/SKILL.md`. SAEED absorbs the compounding loop, not a second delivery pipeline.

### Wiring (codify + feed-forward)

Owner: `continuous-improvement-lead` — the codify step is part of closing a cycle, and the library's shape is theirs. Applying class: `team-orchestrator` and `the-boss` (run the step at cycle close and refuse to record a cycle without it), `product-engineer` and `principal-architect` (the feed-forward search before planning), `self-eval-critic` (grounding validation). Gate: `self-eval-critic` refuses a solutions doc whose claims are not grounded, and `the-boss`'s cycle record is not complete until codify has run or the null result is written down. Deliberately excluded: individual specialists do not file learning docs on their own — findings flow to the harvest passes through `.saeed/retro.md`, which is what keeps the library curated instead of accreted.
