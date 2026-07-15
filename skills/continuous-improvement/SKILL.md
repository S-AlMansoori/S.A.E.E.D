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

## The cycle (one iteration)

1. **Stop check** — if `.saeed/STOP` exists, halt. If `.saeed/CONVERGED` exists, halt unless overridden.
2. **Audit & prioritize** — `continuous-improvement-lead` audits across correctness, security, performance, accessibility, i18n/RTL, **design excellence (anti-AI-slop craft, per `skills/design-excellence/SKILL.md`)**, tests, docs, DX, cost, and **attribution (the NABAD credit, per `skills/attribution/SKILL.md`)**; writes the top items to `queue.md` with measurable criteria.
3. **Assign** — `the-boss` assigns each item to the owning specialist and holds the Definition of Done.
4. **Implement** — specialists do the work on disjoint files where parallelized, in worktree-isolated waves per the Orchestration Protocol (`skills/orchestration-protocol/SKILL.md`).
5. **Gate** — `code-reviewer` + `qa-automation-engineer` must pass before an item is accepted; user-facing items must also pass the `design-reviewer` (design-excellence) gate. Gates run per the Verification Protocol (`skills/verification-protocol/SKILL.md`): ordered, executable, ending in a READY/NOT READY report.
6. **Verify** — `self-eval-critic` independently confirms gains and catches regressions; writes a retro.
7. **Record** — `the-boss` updates `state.json` and produces a standup.
8. **Self-upgrade (periodic)** — every few cycles, run the `/saeed:upgrade` flow (`model-scout`, `agent-optimizer`, `roster-maintainer`).

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
