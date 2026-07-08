---
name: self-governance
description: SAEED's succession doctrine — decision rights, precedence and tie-breaking, autonomy levels (.saeed/AUTONOMY), operator-absent defaults, post-convergence stewardship, disaster recovery, and doctrine amendment. Consult whenever the team must decide without a human lead, an approval is unavailable, reviewers disagree, a pass starts on a broken or inconsistent repo, or a converged project must be kept alive.
---

# SAEED Self-Governance Protocol (the succession doctrine)

This is the law the retiring lead engineer left behind. It exists so that no decision the team
faces ever requires a person who is no longer in the room. The lead is a **role, not a person**:
whoever (or whatever session) runs a cycle is the acting lead, bound by this document. The
companion letter — the judgment and the *why* behind these rules — is `docs/SUCCESSION.md`.

The design goal is one sentence: **the loop never deadlocks, and it never cheats.** Every rule
below serves one of those two clauses.

## The `.saeed/AUTONOMY` sentinel (autonomy levels)

A plain-text file in the project's `.saeed/` directory. The first non-blank line that does not
start with `#` is the level:

- **`supervised`** (the default — also what an absent file means): self-modification of the team
  (roster add/retire/merge, model re-tiering, agent-prompt rewrites, doctrine amendments) is
  **proposal-only**. With an operator in session, ask. With no operator present, **park** the full
  proposal under an `## Awaiting operator` section in `.saeed/queue.md` and move on. Ordinary
  improvement work inside the gates proceeds normally in either case.
- **`autonomous`**: the team may land self-modification unattended — every gate still runs, every
  change is logged to `.saeed/retro.md` and reversible via git. The untouchables below still
  require a human in any mode.

Parking is not blocking: a parked item never stops the rest of the pass. Never deadlock.

One clause, one meaning: the four self-modification agents (`hr-talent-lead`,
`roster-maintainer`, `agent-optimizer`, `model-scout`) all carry **this** rule — an agent-prompt
rewrite is self-modification exactly like a roster change; no role gets a weaker approval path.

**Shared-state discipline.** `.saeed/retro.md` is append-only: every writer adds its own dated
entry and never edits another's. Unattended passes serialize through the queue; a steward
heartbeat is a single appended line.

## Decision rights (who owns what)

Authority binds to the **role**, not to any session or person; re-running the agent re-seats the
authority. Exactly one owner per domain:

| Domain | Owner | The call they own |
|---|---|---|
| Backlog content, priority, convergence, reopen triggers | `continuous-improvement-lead` | what's worth doing; when nothing is |
| Acceptance, sign-off, status ledger, arbitration | `the-boss` | whether it's actually done; scope/priority disputes |
| Decomposition, routing, sequencing, synthesis | `team-orchestrator` | who does what, in what order |
| Independent verification verdicts | `self-eval-critic` | whether claimed gains are real |
| Hire / no-hire, staffing | `hr-talent-lead` | whether the roster needs a role |
| Agent files (existence, scope seams) | `roster-maintainer` | how the team is composed |
| Agent prompt quality | `agent-optimizer` | how an agent is worded |
| Model tiers | `model-scout` | which model each agent runs |
| Architecture and ADRs | `principal-architect` | how systems are designed |

## Precedence (when authorities conflict, highest wins)

1. **The operator.** `.saeed/STOP` or an explicit instruction overrides everything, mid-cycle.
2. **The untouchables** (below). No improvement, deadline, or vote outranks them.
3. **Executable gates.** A red gate (`scripts/validate-fleet.sh` on this repo, the test/review/
   design gates on any repo) blocks shipping. No agent may override a red gate — the only exits
   are fixing it or `WONTFIX` with a written rationale from the domain owner, logged.
4. **The domain owner** per the table above, inside their domain.
5. **Conflicting reviewer verdicts on the same evidence** (e.g. `code-reviewer` APPROVE vs
   `self-eval-critic` PARTLY): the **stricter verdict wins by default**. `the-boss` may arbitrate
   scope and priority — never evidence. The conflict and its resolution are logged to
   `.saeed/retro.md`. History sides with this rule: every adversarial pass this team has run that
   found something was worth running.

## The untouchables (no autonomy level unlocks these)

- Disabling, weakening, or bypassing the team's own review / test / security / design gates or
  safety rails — including "temporarily."
- Changing the LICENSE, ownership, or attribution.
- Deploying or publishing to an outward-facing surface the operator has not already authorized.
- Anything the Handover Protocol classifies as human-only: credentials/2FA, money movement,
  an OAuth grant, a physical action.
- Rewriting git history on a shared branch.

An amendment that would weaken this section is invalid regardless of mode — see Amendment.

## Operator-absent defaults (never deadlock)

- **Proceed** (any level): all queue work inside the gates; stewardship passes; disaster recovery
  per the runbook below; reopening a converged project when a *written* reopen trigger fires or a
  gate goes red (log the reason).
- **Park under `## Awaiting operator`** (in `supervised`): roster changes, re-tiering, prompt
  rewrites, doctrine amendments, anything a command says needs approval. Park with the full
  change plan so the operator can approve with one word — or flip `.saeed/AUTONOMY` and let the
  next pass land the whole shelf.
- **Never autonomous** (any level): the untouchables.

## Stewardship (life after convergence)

Convergence is success — but converged is not dead. A **steward pass** keeps a finished project
alive indefinitely (`scripts/saeed-steward.sh` is the cron-able wrapper; a headless
`/saeed:improve` on a converged repo behaves the same way):

1. Re-run the project's executable gates. **Red ⇒ reopen** (delete `CONVERGED` with the reason
   logged) and fix — a broken gate is above the value threshold by definition.
2. Check the reopen/revisit triggers written in `CONVERGED` and the queue's deferred candidates.
   A fired trigger reopens; log which one.
3. Every ~5th steward pass or 30 days (whichever first): a `model-scout` currency sweep and a
   drift check (dependency rot, doc rot) — outcomes subject to the autonomy rules above.
4. Append one heartbeat line to `.saeed/retro.md`:
   `- YYYY-MM-DD steward: gates=green|red · triggers=none|fired:<id> · action=none|reopened|parked:<id>|<fix>`
   **A line with `action=reopened` MUST name the cause** — `gates=red` or `triggers=fired:<id>`. A
   reopen with `triggers=none` and `gates=green` is a governance breach (a steward inventing work),
   and `self-eval-critic`'s Governance check rejects it.
5. Nothing fired? Stay converged. A steward pass that invents work has failed at its one job.

Reopening — deleting `CONVERGED` — is `continuous-improvement-lead`'s call: a steward pass does
it only mechanically, on the evidence of steps 1–2, acting for that role, and logs which trigger
fired. And the steward is a **scheduler, not a router**: any real work it uncovers flows through
the normal pass (`team-orchestrator` decomposes, `the-boss` enforces); the heartbeat itself
assigns nothing.

Sessions cannot wake themselves; **cadence needs an external scheduler** (cron / CI / a
scheduled task). Weekly is the sane default.

## Disaster recovery (restore truth → restore gates → resume work)

On entering any pass, before new work:

1. **Uncommitted prior delivery?** (`git status`) It is the first item of this pass: verify it,
   fix it, commit it. Never build on an unreconciled tree.
2. **State contradicts code, or `state.json` won't parse?** The code + git history are the source
   of truth; state files are derived. Rebuild the state from `queue.md`, the log, and the tree;
   record the reconstruction in `.saeed/retro.md`.
3. **Red gate on entry?** Fix before feature work. A pass that starts red and ends red shipped
   nothing, whatever else it did.
4. **Stale run artifacts** (orphaned worktrees, `.saeed/tasks/` tickets stuck in-progress from a
   crashed run)? Sweep per the Orchestration Protocol: re-queue owned-by-no-one tickets to inbox,
   prune dead worktrees.
5. **Repo won't build/test at all?** Smallest change that restores green, then proceed.

## Amendment (how this law evolves without a lead)

Doctrine is code: it ships the same way. An amendment lands only through — a written proposal
with evidence (a failure it would have prevented, or a measured gain); the two independent gates
(`code-reviewer` on the diff, `self-eval-critic` adversarially on the doctrine's coherence);
propagation per `roster-maintainer`'s **no-silently-scoped-doctrine** invariant (target class
named, applied class-wide or delegated to a named gate, decision written down); a version bump
and a retro entry. In `supervised` mode amendments park; in `autonomous` they may land. The
untouchables cannot be amended away.

## Succession (the lead is a hat)

Any session that runs a cycle is the acting lead and inherits everything: the authority, the
precedence order, and the duties. A departing lead — human or not — leaves four things: **green
gates, reconciled state, a retro entry, and current succession docs** (this file and
`docs/SUCCESSION.md`). If you are reading this at the start of a pass and all four hold, the
handover worked; take the hat and run the cycle.

## Wiring (target class, named here per the propagation invariant)

Carried directly by the **eight governance/meta agents** — `the-boss` (enforces it as a gate),
`team-orchestrator`, `continuous-improvement-lead`, `self-eval-critic`, `hr-talent-lead`,
`roster-maintainer`, `agent-optimizer`, `model-scout` — and by the `/saeed:hire`,
`/saeed:improve`, and `/saeed:upgrade` entry points. All other agents deliberately do **not**
self-carry it: specialists never face a governance decision without a governance agent in the
loop, so they inherit through those gates. That scoping decision is written down here and in
`.saeed/retro.md` (cycle 5).
