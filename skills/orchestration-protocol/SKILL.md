---
name: orchestration-protocol
description: SAEED's absorbed parallel-build and delivery discipline — the house standard for running multi-agent work safely at scale. Distills the claude-sdlc-kit (kit-bootstrap / kit-ingest / kit-orchestrate / kit-integrate / kit-qa) into wave-based orchestration, worktree isolation, a shared ticket queue, self-contained targeted briefs, executable gates, commit discipline, integration-as-a-separate-run, adversarial parallel QA, and provenance-tagged corpus ingestion. Consulted automatically whenever SAEED parallelizes work, merges branches, runs heavy QA, or turns a BRD into a build.
---

# SAEED Orchestration Protocol — the absorbed delivery discipline

SAEED has absorbed the **claude-sdlc-kit** methodology for running many agents in parallel without chaos. These practices are now house standard: any time `team-orchestrator` fans work out, `the-boss` gates it, `qa-automation-engineer` runs heavy QA, or the team turns a spec corpus into a build, it follows this protocol. It complements the `continuous-improvement` loop (what to do next) with **how to do it in parallel, safely, and prove it.**

## When this applies

Multi-step builds, audits, migrations, or improvement passes that spread across more than one or two disjoint modules; any branch integration; heavy browser QA; and any "from BRD/spec corpus to tested app" build. For a single-file edit or one research delegation, skip this — just do the edit or spawn one `Agent`.

## The wave model

Work runs in **sequential waves; parallel within a wave is the default and the whole point.**

| Wave | Role | Parallelism |
|---|---|---|
| **0 — Plan** | Orchestrator alone | Single-threaded. Read the governing spec/KB + acceptance criteria, capture an executable **baseline** keyed to the current HEAD SHA, write the run-plan (workstreams, branches, gates). |
| **1 — Discovery** | Producers | All in parallel. Producers **file tickets** for what needs doing/fixing; they do NOT change product code. |
| **2 — Fix / Close** | Consumers | All in parallel, each in its **own git worktree**, owning one module's file globs. Each drains the queue filtered by its role + area and closes or escalates tickets. |
| **3 — Re-verify** | Re-verifier | Re-runs the full gates against the fixer branches; files any new red as a ticket. Never spawns until every Wave-2 consumer has returned. |
| **Consolidate** | Orchestrator alone | Drains escalations into the operator report. **Never auto-merges** — surfaces integration order + known conflicts. Integration is a separate run. |

## Worktree isolation (mandatory for parallel mutation)

Parallel agents that write files each run in their **own git worktree** (`isolation: "worktree"`) on their own branch. They own one module's globs, append (never rewrite) one line per shared seam, commit to their branch, and **never push**. This is what makes parallelism safe rather than a merge disaster. The main working tree is read-only for sub-agents — no `checkout`/`merge`/`rebase`/`stash pop` in it. Two tasks that touch the same files are serialized, not parallelized.

## The shared ticket queue

The queue is the only shared state between parallel agents. SAEED keeps it under `.saeed/` (`queue.md` as the human ledger; a `.saeed/tasks/{inbox,in-progress,done,escalated}/` tree when a run is large). Every ticket carries frontmatter:

```yaml
id: w<wave>-<workstream>-<seq>        # e.g. w1-real-api-03
consumer_role: fixer-web | fixer-api | fixer-ios | fixer-android | re-verifier | escalate
priority: critical | high | medium | low
area: web | api | mobile | data | infra | a11y | design | perf | docs
blocked_by: <ids or none>
finding_ref: <path#anchor or n/a>
```

Lifecycle: `inbox → in-progress` (on pickup, stamp branch + start) `→ done` (stamp `## Resolution`: what changed, commit SHA, gate result) or `→ escalated` (stamp reason). A producer never edits its own ticket after writing it; corrections go in a new ticket.

## Self-contained, targeted briefs

Every sub-agent brief is **self-contained**: the orchestrator pre-resolves `file:line` pointers and inlines all static facts (hard rules, conventions, today/infra/auth). Sub-agents act on the brief; they do not go re-read protocol docs to bootstrap.

**Turn vague briefs into targeted ones** (bad → good):
- "Fix the status bug." → "Fix `transitionStatus()` at `api/src/activity.ts:142`. Failing test: `activity.test.ts:88`. Asserts `EXEC`; actual `null`. Do NOT touch `state-machine.ts`."
- "Explore the codebase to find X." → "X is at `web/src/X.tsx:120-180`. Callers: `Y.tsx:45`, `Z.tsx:88`."
- "Don't break anything." → "Forbidden paths: `packages/contracts/*`, `api/migrations/*` (frozen)."
- "Return when done." → "Report `Status: DONE | DONE_WITH_CONCERNS | NEEDS_CONTEXT | BLOCKED` first line, then evidence."

Cap briefs ~500 lines / ~6 full-inline agents per wave. If a ticket can't be made concrete in three tries, it's under-specified — split or defer it.

**Four-state report-back** (first line is the status; the orchestrator branches on it):
- `DONE` — acceptance met cleanly.
- `DONE_WITH_CONCERNS` — met, but flagged doubts; read concerns first.
- `NEEDS_CONTEXT` — brief incomplete; re-dispatch with the missing context (same model).
- `BLOCKED` — cannot complete; triage (more context / escalate model / split ticket / escalate to operator).

## Executable gates, run by the orchestrator

Gates are **executable and run by the orchestrator/the-boss — never trust an agent's self-declared "done".** Capture a baseline before Wave 1; re-run typecheck / lint / unit / integration / e2e / a11y per branch. Tag a checkpoint before any protected-core, schema, or migration change.

## Commit & branch discipline

- **Conventional commits** only: `feat(api):`, `fix(web):`, `test(ios):`, `chore(orch):`, `docs:`, `perf:`, `refactor:`. Body explains WHY; footer carries `Closes:` and `Risk: HIGH|MEDIUM|LOW`.
- **Logical-boundary commits**, one per closed ticket — never a single end-of-session mega-commit, never "WIP"/"checkpoint" left in the tip.
- **Every commit is independently green** (typecheck + lint exit 0 at each SHA).
- Branch naming `<track>/<phase>-<slug>`. **Never** push, force-push, `--no-verify`, amend, or auto-merge across branches. Only the integration run rewrites history, and only on a fresh `*-atomic` branch.

## Integration is a separate, gated run

Never merge feature branches inside a build/discovery run. Integration is its own deliberate pass:
1. **Pre-merge review gate** — a senior (Opus) reviewer over the candidate branches; its critical findings become tickets drained before any history rewrite.
2. **Baseline + tag** a checkpoint before touching anything.
3. **Merge in documented order**; `.gitattributes merge=union` pre-resolves append-only-doc conflicts.
4. **Re-emit as atomic commits** — cherry-pick by file-set onto a fresh `*-atomic` branch, each commit independently green, conventional messages with `Closes:`/`Risk:`.
5. **Regenerate shared artifacts once** (contracts version bump, OpenAPI/types) — the version bump is the only cross-track coordination signal.
6. **Gate the whole thing** and produce an INTEGRATION-REPORT (input branches, conflicts, atomic-commit plan, gate results, recommended merge order). Do NOT push or open a PR — hand the operator a clean, reviewed branch.

## Adversarial parallel QA (heavy browser testing)

For serious QA, a cheap tester fleet plus an expensive adversarial reviewer:
- **One orchestrator (Opus)** plans personas and re-verifies; **N browser-testers (Sonnet)** confined to browser-only tools (Playwright MCP), each emitting findings as its final message (testers cannot write files, so the log tail IS the deliverable).
- **Rollout: canary one persona → cap ~4 concurrent → two waves.** Synthetic seed data only; never regulated/PII on a non-approved box.
- **Mandatory Phase-3 adversarial verification:** do not pass tester findings through raw. Re-verify every Critical and every RBAC/authz claim in your own authenticated session — capture the **POST/PUT/PATCH status code AND hard-reload** to prove persistence, not optimistic UI. Build the **corroboration matrix** (VERIFIED / CORROBORATED / SINGLE / DOWNGRADED) and record the reason for every downgrade before writing the report. Confirmed findings become queue tickets routed by `consumer_role`.

This is the trust layer: a cheap model optimistic-passes and severity-inflates; the report is only trustworthy because Opus treated every claim as a hypothesis until POST-status-plus-reload evidence.

## Corpus ingestion (BRD → agent-searchable KB)

When requirements arrive as a multi-format corpus (`.docx/.pptx/.pdf/.xlsx/.vsdx`, often bilingual or scanned), build the KB **before** any feature code: a mirrored tree of grep-able markdown where every file has a `> Source:` provenance line, native requirement IDs are preserved **verbatim** as grep targets, process flows are dual-captured (step text + rendered diagram), and OCR/bilingual-RTL degradation is flagged in per-area manifests, never silently trusted. `data-engineer` owns the pipeline; `product-engineer` cites the KB when writing specs. Excluded/stale sources are recorded so no one cites a superseded requirement.

## Memory-on-opinion

When the operator states a preference, a non-obvious project fact, or corrects a recommendation mid-run, write it to project memory immediately (`~/.claude/projects/<project>/memory/` + a pointer in `MEMORY.md`). Preferences do not survive on transcript alone.

## Cross-session safety & cleanup

Multiple sessions on one machine interfere unless isolated: claim a session lock, suffix branch names with a session id, and at clean exit **remove only your own fully-merged, clean worktrees/branches** (`git branch -d`, never `-D`; never touch dirty or unmerged work — surface it instead).

## Definition of done (orchestrator exit criteria)

Gates green · pass-rate ≥ project floor · queue drained (done or escalated) · re-verifier confirms no new reds · operator report with verdict-per-workstream + RED tracker + branch table + recommended integration order · checkpoint tagged only if every workstream is green · session artifacts cleaned up (dirty/unmerged items listed, never dropped silently).

## Controller mechanics: ledger, capped fix loops, model economics

The wave model above says *who* runs in parallel. This section says *how one controller drives its sub-agents through to green* — the delta SAEED absorbed from **obra/superpowers** (`using-git-worktrees`, `dispatching-parallel-agents`, `executing-plans`, `subagent-driven-development`). The engineering method those sub-agents work under — the TDD Iron Law, four-phase debugging, the plan law, and the S/M/L applicability ladder that decides how much of this ceremony a task earns — lives in `skills/engineering-method/SKILL.md` and is **not restated here**.

### The workspace and the progress ledger

Conversation memory does not survive compaction. Controllers that lost their place have re-dispatched entire completed task sequences — the single most expensive controller failure on record. **Todos are not a record. The ledger is.**

- Each run owns one git-ignored directory (`.saeed/tasks/<run-id>/`, alongside the ticket queue): briefs, reports, review packages, and `ledger.md` for THIS run and no other. Another run's directory is never yours to read or write.
- The ledger's first line is its identity — `# Run ledger — plan: <path>`. A ledger naming a different plan is someone else's progress: leave it in place and start your own, fresh.
- **Resume rules.** A task carrying a `Task <N>: complete` line is DONE — never re-dispatch it; resume at the first task without one. A task whose last line is a fix round is mid-loop — resume at the next round.
- After compaction, trust the ledger and `git log` over your own recollection: the commits it names exist in git even when your context no longer remembers creating them. The workspace is scratch (`git clean -fdx` deletes it); the git history is the durable record.
- Every dispatch, every fix round, every ruling appends one line. A silent discard is forbidden.

### Dispatch discipline

- **Fresh sub-agent per task.** Sub-agents never inherit session history — you construct exactly what they need (see the targeted-brief rules above). Never paste accumulated prior-task summaries into a later dispatch: one real session's prompt reached 42k characters of which 99% was pasted history.
- **Hand artifacts over as file paths, not pasted text** — brief in, report out, diff package in. Anything pasted into a dispatch, and anything a sub-agent prints back, stays resident in your context and is re-read on every later turn.
- **Record BASE (`git rev-parse HEAD`) before dispatching.** Review packages and fix diffs are cut from it — never from `HEAD~1`, which silently drops all but the last commit of a multi-commit task.
- **Never run two implementers over the same files**, in parallel or interleaved — that is the worktree rule at task granularity. Independent domains fan out in a single response; one dispatch per response is sequential by accident.
- Never start implementation on `main`/`master` without the operator's explicit consent. **The controller never fixes findings itself** — controller fixes pollute the coordination context and skip review.
- Review after every task, on **both** axes (spec compliance AND quality); a report missing either verdict is not a review. An implementer's self-review never substitutes. The broad whole-branch review happens once, at the end.
- **Never pre-judge findings for a reviewer.** If the dispatch you are writing contains "do not flag", "don't treat X as a defect", or "at most Minor" — stop: you are buying your way out of a review loop.

### The capped fix loop

A fix round is one fix dispatch plus one scoped re-review. **Five rounds maximum per task.**

| Round | Who fixes | Why |
|---|---|---|
| **1–3** | Resume the original implementer with the open findings verbatim | Its context is intact — it knows the task, the code, and its own choices. |
| **4–5** | Fresh implementer one tier up, framed "a prior implementer attempted this N times; you own it now — read the report file for what was tried" | A loop that survives three resumes means the implementer cannot see its own problem: fresh eyes and a capability bump in one move. |

- **Minor findings never enter the loop** — they land in the ledger as deferred minors, and the final review is pointed at that list to triage what must be fixed before merge. A roll-up nobody reads is a silent discard.
- A finding that contradicts the plan's own text is the operator's call: present the finding beside the plan text and ask which governs. Do not dismiss the finding because the plan mandates it, and do not dispatch a fix that contradicts the plan.
- Every round ends with a **scoped** re-review over the fix diff only, verdicting each finding ADDRESSED / NOT ADDRESSED. New Critical/Important breakage inside that diff joins the open list; out-of-scope observations go to the ledger and never extend the loop.
- **The breaker.** If round 5's re-review still leaves findings open, stop dispatching and adjudicate each one in writing: contestable, or real-but-nothing-downstream-builds-on-it → park with a ruling; real and load-bearing → `BLOCKED`, escalated with the finding, the plan text it collides with, and the fix history. Parking a structural failure lets every dependent task build on it and hands the final review a problem it cannot fix either.
- **Adjudicate only at the cap.** Adjudicating early to end a loop is pre-judging under a different name.
- The final whole-branch review gets **one** fix wave (a single sub-agent carrying the complete findings list — never one fixer per finding, which rebuilds context and re-runs suites N times) and exactly one scoped re-review. There is no second wave; residuals are adjudicated the same way and surfaced to the operator.

### Model economics at dispatch time

Pick the **least capable model that can hold the role**, and **always name it explicitly** — an omitted model inherits the session's, usually the most expensive, which quietly defeats this whole section. This governs how a controller dispatches; it changes no agent's declared `model:`.

- Transcription-grade work (the brief already contains the code to write; single-file mechanical fixes) → cheapest tier.
- Implementers working from prose, and all reviewers → mid tier as the **floor**. **Turn count beats token price:** the cheapest models routinely take 2–3× the turns on multi-step work and cost more overall.
- Multi-file integration, debugging, and pattern-matching → standard tier. Design judgment, seam decisions, and the final whole-branch review → the most capable tier available.
- Fix rounds 4–5 → at least one tier above the implementer that got stuck.
- Reviewers scale to the diff: a small mechanical diff does not need the top tier; a subtle concurrency change does.

## Attribution

This protocol distills, with gratitude, the **claude-sdlc-kit** (`kit-bootstrap`, `kit-ingest` / `corpus-ingestion`, `kit-orchestrate` / `orchestrator-protocol`, `kit-integrate`, `kit-qa`, and its `parallel-browser-qa` recipe and `LESSONS.md`). When the kit is installed, prefer invoking those commands for the full tooling; this file guarantees the discipline when it is not.

The controller-mechanics section above distills, with gratitude, **obra/superpowers** (`using-git-worktrees`, `dispatching-parallel-agents`, `executing-plans`, `subagent-driven-development`). When that plugin is installed, prefer its skills and scripts for the full workflow. Never let a missing plugin lower the bar.
