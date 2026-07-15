---
name: context-discipline
description: SAEED's context, memory, and model-routing canon (absorbed from the ECC / Everything Claude Code methodology). Consult when planning long sessions or parallel runs, deciding when to compact, choosing a model tier for a task, briefing subagents, or capturing learnings — it defines strategic compaction, write-before-compact, the .saeed/ memory contract, confidence-scored instincts, and subagent context negotiation.
---

# SAEED Context Discipline (the memory & attention canon)

Absorbed and adapted from the ECC ("Everything Claude Code") strategic-compact,
continuous-learning, and session-persistence canons. The one-line doctrine:
**context is a budget and disk is the bank** — anything worth keeping gets
written to `.saeed/` before it can be lost, and the window is spent on the
task, not on residue.

## Strategic compaction (compact on purpose, not by accident)

Auto-compaction fires at an arbitrary moment and keeps what a summarizer
guesses matters. Compacting *at a phase boundary* keeps what you chose to
write down. Rules:

- **Compact between phases, never mid-implementation**: after research →
  before planning; after a plan is approved → before building; after a
  failed approach is abandoned (drop the dead weight); after a pass's
  Verification Report is recorded.
- **Write before compacting.** What survives compaction: files on disk,
  git history, `.saeed/` state (queue, state.json, retro, instincts).
  What dies: intermediate reasoning, earlier file reads, verbal agreements.
  If a decision, constraint, or open question lives only in conversation,
  put it in `.saeed/queue.md` or `.saeed/retro.md` first.
- **Avoid the last 20% of the window for heavy work.** Don't start a large
  multi-file refactor with a nearly-full context; compact first, or split
  the work into ticketed waves per the Orchestration Protocol.

## The `.saeed/` memory contract

`.saeed/` is the team's durable memory across sessions and compactions (see
`skills/continuous-improvement/SKILL.md` for the file inventory). The plugin's
`session-brief` hook injects a snapshot at every session start — autonomy
level, sentinels, queue counts, parked approvals, last retro line — so a
fresh session resumes from the ledger instead of re-deriving it. The brief
is a summary, not instructions: verify against the files before acting.

## Instincts (learnings with a confidence score)

A lesson the team keeps re-learning is a defect in memory, not in skill.
Capture recurring lessons as **instincts** in `.saeed/instincts.md` — one
per entry, atomic:

```markdown
- trigger: <the situation that should fire this>
  action: <the one behavior to apply>
  confidence: 0.3–0.9   # start 0.5; +0.1 each confirmation, −0.2 on contradiction/operator correction
  evidence: <retro/queue refs, count of observations>
```

- **One trigger, one action.** A paragraph of advice is not an instinct.
- ≥ 0.7 → apply by default; < 0.5 for two passes → prune it.
- Project-shaped instincts (naming, layout, framework conventions) stay in
  the project's `.saeed/`. Universal ones (git discipline, security habits)
  are candidates for **promotion into the plugin itself** — an agent prompt
  or skill edit via the `/saeed:upgrade` flow, proposed by
  `continuous-improvement-lead` / `agent-optimizer` with the instinct's
  evidence attached, gated like any self-modification.
- `self-eval-critic` owns the honesty of the scores: an instinct that never
  fires, or fires and misleads, gets downgraded in the retro.

## Model routing (spend reasoning where it pays)

The fleet's standing tiers live in agent frontmatter and `.saeed/models.md`
(managed by `model-scout`). Within a task, route like this:

| Work | Tier |
|---|---|
| Mechanical, low-risk, high-volume (renames, lookups, formatting sweeps) | fast tier |
| Implementation, refactors, PR review — the default | mid tier (Sonnet) |
| Architecture, security-critical, ambiguous, or deep-debug work | top tier (Opus) |

**Upgrade triggers** — move one tier up when: the first attempt failed; the
change spans 5+ files; the decision is architectural; or the work is
security-critical. Downgrading a task to save cost after a failure is
false economy.

## Subagent context negotiation

A subagent knows only what its brief says — it cannot see the purpose behind
the task (Orchestration Protocol: briefs are self-contained). Additionally:

- **Pass the objective, not just the instruction**, so the subagent can make
  aligned micro-decisions instead of literal-minded ones.
- **Evaluate every return** against the objective before consuming it; ask
  follow-ups, but cap at ~3 cycles — past that, re-scope the brief instead.
- **Intermediate outputs go to files** (ticket dirs, `.saeed/`), not into
  the orchestrator's window; the orchestrator keeps conclusions, not dumps.

## Tool surface budget

Every always-loaded tool schema and MCP server rents context in *every*
turn. Keep the enabled surface small: prefer a CLI invoked from Bash (or a
lazily-loaded skill) over an always-on MCP server that duplicates it; enable
heavyweight connectors for the session that needs them, not globally. When a
session feels cramped before work begins, audit the tool surface first.

## Wiring

- `team-orchestrator` — compaction boundaries, subagent negotiation, files-not-dumps.
- `model-scout` — owns the standing tiers this canon's routing table feeds.
- `continuous-improvement-lead` / `agent-optimizer` — instinct capture and promotion.
- `self-eval-critic` — audits instinct confidence honestly.
- `hooks/session-brief.sh` — the mechanical floor: state is re-injected at session start.
