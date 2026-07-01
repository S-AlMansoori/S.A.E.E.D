---
name: continuous-improvement
description: The shared protocol and state-file convention for SAEED's autonomous improvement loop. Consult when running or reasoning about /saeed:improve, the .saeed/ state directory, convergence, or how the team keeps working on a project without supervision.
---

# SAEED Continuous-Improvement Protocol

This skill defines how the team works on a handed-over project continuously and how it knows when to stop. All agents share this convention.

## The `.saeed/` state directory

Every managed repo gets a `.saeed/` directory:

- `queue.md` — the prioritized improvement backlog. Each item: `id | title | owner-agent | acceptance-criteria | status`. Status is one of `TODO / IN_PROGRESS / IN_REVIEW / DONE / REJECTED / WONTFIX`.
- `state.json` — machine-readable ledger of items, cycle count, and last-updated timestamp.
- `retro.md` — append-only log of retrospectives, agent-optimization notes, and roster/model changes.
- `models.md` — current model tiering (which agent runs on which model) with change history.
- `CONVERGED` — sentinel file. Present ONLY when the `continuous-improvement-lead` has decided, with evidence, that no improvement above the value threshold remains. Its contents explain why.
- `STOP` — sentinel file. Present when the human has halted the loop. Overrides everything.

## The cycle (one iteration)

1. **Stop check** — if `.saeed/STOP` exists, halt. If `.saeed/CONVERGED` exists, halt unless overridden.
2. **Audit & prioritize** — `continuous-improvement-lead` audits across correctness, security, performance, accessibility, i18n/RTL, tests, docs, DX, cost; writes the top items to `queue.md` with measurable criteria.
3. **Assign** — `the-boss` assigns each item to the owning specialist and holds the Definition of Done.
4. **Implement** — specialists do the work on disjoint files where parallelized.
5. **Gate** — `code-reviewer` + `qa-automation-engineer` must pass before an item is accepted.
6. **Verify** — `self-eval-critic` independently confirms gains and catches regressions; writes a retro.
7. **Record** — `the-boss` updates `state.json` and produces a standup.
8. **Self-upgrade (periodic)** — every few cycles, run the `/saeed:upgrade` flow (`model-scout`, `agent-optimizer`, `roster-maintainer`).

## Definition of Done

An item is DONE only when: acceptance criteria met AND reviewed AND tested AND documented AND independently verified. No self-attestation without evidence.

## Convergence (the honest stop)

The loop is designed to terminate. When a full audit surfaces nothing above the value threshold (i.e., remaining ideas are churn, speculative rewrites, or cosmetic), the `continuous-improvement-lead` writes `.saeed/CONVERGED` with the evidence rather than manufacturing busywork. Convergence is success.

## Human overrides

- Drop a `.saeed/STOP` file (or run `/saeed:stop`) to halt immediately, mid-cycle.
- Delete `CONVERGED` and run `/saeed:improve` to resume with new goals.
- Self-modification of the team (roster/model changes) requires human approval unless autonomous self-modification is explicitly enabled by the operator.

## Safety rails

- The team never disables its own review/test/security gates to make progress.
- Roster and model changes are reversible and logged.
- Destructive actions (deleting agents referenced by open items, destructive migrations) are blocked.
