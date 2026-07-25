---
name: repo-housekeeping
description: SAEED's workspace-stewardship canon — git hygiene and untracked-file triage (commit over delete, with the secrets exception), two-copies and upstream sync discipline, knowledge distillation from recent sessions, organizational and orientation-file audits, working-file triage, and close-out reporting. Tends the workspace between product cycles; the improvement loop tends the product.
---

# SAEED Repo Housekeeping — the absorbed workspace canon

SAEED has absorbed the `repository-housekeeping` skill and generalized it off its chat-bot origins. Its lesson is one sentence: **a repo decays quietly, and the decay is only ever cheap to fix early.** Loose files become lost decisions, an unsynced second copy becomes an un-ledgered release, and knowledge that stayed in a transcript is knowledge the next pass pays for again.

A housekeeping pass leaves the workspace **committed, synced, indexed, and honestly reported** — nothing more. It is a runbook, executed start to finish, not a set of habits.

## When this applies (and when it does not)

Housekeeping tends the **workspace**. The improvement loop in `skills/continuous-improvement/SKILL.md` improves the **product**. That seam is the whole scope of this canon: a pass tidies, syncs, and distils; it does not decide what the product should become, and it never declares convergence.

- **Runs:** periodically, as the steward branch of a pass (cadence inherits the stewardship section of `skills/self-governance/SKILL.md` — no new scheduler, no new sentinel); on demand when the operator asks for a housekeeping pass; and in miniature (steps 1, 7, 8) at every release close-out.
- **Does NOT apply per-change.** No task waits on a housekeeping pass. This canon adds **zero** per-change gates — the S/M/L ladder in `skills/engineering-method/SKILL.md` scopes those, and a one-line fix meets exactly the gates it met before this file existed.
- **The one place it binds a delivery** is the Workspace-clean DoD in `agents/the-boss.md` (the workspace half of the same truth standard as its State-file-truth DoD). Skipping *that* — or committing around a red gate to make a tree look clean — is gate-weakening, untouchable #1 in `skills/self-governance/SKILL.md`.

## Invoke the deep skill (when the Skill tool is available to you)

| Task in front of you | Invoke |
|---|---|
| A full repo-gardening pass, with its own step-by-step | `repository-housekeeping` (mikesol / cc-disco, via mcpmarket) |

Invoke it for depth and fold its output into the steps below; the house rulings here — the secrets exception, the two-copies check, the handover ladder, the product/workspace seam — override anything the source says about Discord, cc-disco layouts, or asking the user to do setup work. If it is not installed, the runbook below still fully applies. Never let a missing plugin lower the bar.

## The pass — eight steps

Work them in order, committing progress as you go. **One exception:** on the SAEED plugin repo itself, step 2's drift check runs **before** step 1 — you cannot triage a tree you have not reconciled.

### 1. Git hygiene

Start from evidence: `git status`, then `git diff --stat`. Never triage from memory of what you changed.

Every untracked file gets exactly one verdict — **commit**, **gitignore**, or **delete**:

- **Default: commit.** Git history is cheap; lost knowledge is not. If you are unsure whether a file matters, commit it — a wrong commit is one revert away, a wrong deletion is gone.
- **Gitignore** the clearly transient: build artifacts, caches, logs, coverage output, mid-session screenshots, local editor state.
- **Delete** only what is both transient *and* re-derivable. Anything you cannot re-derive gets committed first and removed in a later commit, so history holds it.

**The secrets exception (absolute — the default inverts here).** `.env` files, credential stores, private keys, tokens, and service-account JSON are **never** committed "to be safe". They go to `.gitignore`, and the deny-read rules that keep an agent from reading them in the first place live in `skills/agentic-security/SKILL.md`. If such a file is already tracked, that is not a housekeeping item — it is a leak: stop the pass and run the secrets response protocol in that canon. Do not silently `git rm` it and continue; history still holds it.

Then: commit in **logical units** (never batch unrelated changes into one commit), in the repo's conventional-commit format, and push.

### 2. Sync discipline — the two-copies drift check

**Standing rule:** SAEED exists in at least **two copies** — the operator's working copy and the **installed plugin clone** — plus `.saeed/`, which is a *derived* ledger, not a third source of truth. At the start of any pass on the SAEED plugin repo, fetch and reconcile all three before touching anything else.

```bash
git -C <working-copy> fetch --all --prune && git -C <working-copy> status -sb
git -C <installed-plugin-clone> fetch --all --prune && git -C <installed-plugin-clone> log --oneline HEAD..origin/main
```

Compare: are both copies on `origin/main`? Does the version in the manifest match the version the ledger claims? Does the ledger record the releases git actually holds?

**Why this is a standing rule and not a nicety — SU-28.** Cycles 6 and 7 shipped from a cloud branch and landed on `origin/main` without the ledger ever being updated; cycle 8 had to reconstruct the record from git history and the changelog. Everything about that incident was cheap to prevent and expensive to repair. When the copies *have* diverged into contradiction, the rebuild rule is not restated here — follow the disaster-recovery runbook in `skills/self-governance/SKILL.md` (code and git are the source of truth; state files are derived).

Upstream reconciliation, where an upstream exists:

- Review what is new upstream before merging. Relevance first, then conflicts.
- **Conflict rule: local customizations take precedence unless upstream is clearly better** — and "clearly better" is a stated reason in the commit message, not a preference.
- **Contribute-back candidates are surfaced and always parked** for the operator (step 8). A pass never opens a PR against someone else's project.
- **No upstream configured?** Do not hand the setup back to the operator as a chore. Run the capability-first ladder in `skills/handover-protocol/SKILL.md`: configure the remote yourself if this session can, drive the surface that can, or park a complete packet — a bare manual ask is the last resort, not the first.

### 3. Recent-session review — distil knowledge before it evaporates

Mine the recent record: session transcripts from the last pass or two, `.saeed/retro.md`, `.saeed/instincts.md`, and — the richest seam — **every place a human corrected the work**.

Ask three questions of each finding:

- **A recurring task or workflow?** → a skill candidate, authored under `skills/canon-craft/SKILL.md`.
- **A durable fact** about a system, service, or repo? → an orientation- or knowledge-file entry (step 5).
- **Did something break and get fixed?** → a gotcha line in the canon that owns the trap.

**Route, do not store.** Findings go through the single knowledge pipeline documented in `skills/continuous-improvement/SKILL.md`, which decides instinct vs solutions doc vs glossary vs orientation file vs promotion into the plugin. The instinct format and its confidence scoring belong to `skills/context-discipline/SKILL.md`. This step feeds that pipeline; it does not open a parallel store, and it restates neither.

**External channels (Slack, Discord, issue trackers, email) are reviewed only where a connector already exists.** No connector means the sub-step is recorded as not-run in the close-out report — never a blocked dependency, never a manual export request that stalls the pass.

### 4. Organizational reflection

Step back from files and look at the repo whole. This step is judgment-driven, not checklist-driven.

- **Consolidation** — is related knowledge scattered across several files? Merge it, or cross-reference it and leave one home.
- **Redundancy** — are two skills or docs half-covering the same ground? Is anything half-finished, or still describing how things *used* to work?
- **Structure and naming** — does the layout still match what the repo has become? Are names consistent, or archaeological?
- **Pruning** — dead code, abandoned ideas, superseded knowledge files.

Close on the coherence test: **would someone coming to this repo fresh find the layout coherent?** If not, fix what you can inside this pass's authority and flag the rest for a bigger conversation. Merges, prunes, and renames are governed by the self-modification rule below.

### 5. Orientation-file audit

Read the repo's orientation and index files end to end — `CLAUDE.md`, `README`, memory or index files, the docs that tell a newcomer where things are. Check for:

- **stale references** — moved paths, dead URLs, credential or channel identifiers that changed;
- **outdated facts** — tools, skills, or infrastructure that no longer exist or work differently;
- **bloat** — sections that grew by accretion; rewrite them tight;
- **missing entries** — new skills, commands, or facts that should be indexed and are not.

**Keep it light: an index, not a manual.** Anything that has grown into a manual moves into the file it documents and leaves a one-line pointer behind. Where the repo is bilingual, the EN and AR surfaces move together in the same commit — a stale mirror is a stale doc.

### 6. Skills audit

For each skill the repo carries: is it still **true** (does it describe the current tool, service, and workflow)? Are the referenced identifiers and paths still valid? Are the gotchas it has caused actually written down in it? Does it overlap another skill enough to merge? Is it simply obsolete?

Canons are held to the conformance floor in `skills/canon-craft/SKILL.md` — that floor is the audit's checklist, not a second one invented here. Removals and merges follow the self-modification rule below.

### 7. Working-files check

Scan the **whole repo** — assume no directory layout. Every non-source file (state files, caches, logs, screenshots, build output, downloaded content, stray scratch files) gets one verdict:

- **Commit** — meaningful persistent state: deduplication state, seeded config, fixtures, decision records.
- **Gitignore** — ephemeral or large: anything a build or run regenerates.
- **Delete** — no ongoing purpose, and re-derivable.

Same default as step 1 (commit when unsure), same absolute exception for anything credential-bearing.

### 8. Close-out — commit, push, report

- Commit whatever remains, in logical units, conventional format. **Push** — and if push is blocked (credentials, network, protected branch), park the exact command rather than silently skipping it.
- Write the status report on four axes: **what was tidied** · **what knowledge was added, and where it landed** · **sync status** (both copies, ledger, upstream) · **what was flagged** (conflicts not resolved, decisions deferred, sub-steps not run and why).
- The report's standing surface is one heartbeat line appended to `.saeed/retro.md` in the format fixed by the stewardship section of `skills/self-governance/SKILL.md`, plus the standup when a pass is running.
- **Unresolved decisions park under `## Awaiting operator` in `.saeed/queue.md`** — the pass reports them, it does not decide them, and it never blocks waiting for an answer.
- On the SAEED repo the pass closes under the **State-file-truth DoD** in `agents/the-boss.md`: state files match the code, verified by the repo's executable check at exit 0. That DoD is the gate; this canon does not restate its terms.

## Self-modification — steps 4 and 6 on SAEED's own repo

Merging, pruning, or renaming SAEED's own skills, agents, or structure **is self-modification**, bound by `.saeed/AUTONOMY` per `skills/self-governance/SKILL.md`. Under `supervised`, a pass produces **proposals only**, parked under `## Awaiting operator` with the evidence — it does not land them, however obvious the cleanup looks.

On **managed repos**, structural prunes and renames go through the project's normal review gates as proposals. A pass tidies a client's workspace; it does not reorganize their codebase on its own authority.

## Unattended passes

A steward-invoked pass runs with no one watching, so its rights are narrower than its abilities:

- It reads broadly and can write and push — the exposure that combination creates is scoped by the lethal-trifecta rule in `skills/agentic-security/SKILL.md`; that rule is not restated here.
- **Push and publish rights follow that canon plus the current AUTONOMY level.** Contribute-back submissions to third parties are **always** parked, at every autonomy level.
- **Never weaken a gate to make a tree clean.** A red gate discovered mid-pass becomes the pass's first item, or a parked finding — never something to commit around.

## What a pass never produces

A housekeeping pass does **not** write product-improvement items as its own output. Product work it stumbles on becomes exactly **one** queue candidate in the close-out report — untriaged, unprioritized, unassigned. Prioritization, acceptance criteria, sequencing, and the convergence decision belong to `skills/continuous-improvement/SKILL.md` and its owner; assignment belongs to `agents/the-boss.md`. A pass that returns with a groomed backlog has crossed the seam this canon exists to hold.

## Entrypoints

1. **Steward pass (primary).** The periodic currency/drift sweep in `commands/improve.md`'s steward paragraph is executed as a housekeeping pass per this canon, at the stewardship cadence already defined in `skills/self-governance/SKILL.md`.
2. **On demand.** "Run a housekeeping pass" in any session executes this runbook top to bottom. There is no command to learn.
3. **Release close-out.** Every release on the SAEED repo runs steps 1, 7, and 8 under the State-file-truth DoD.

## Pass checklist — before reporting done

- [ ] Two copies and the ledger fetched and reconciled (SAEED repo: before anything else).
- [ ] `git status` clean; every untracked file committed, gitignored, or deleted — with a verdict, not by omission.
- [ ] No credential-bearing file committed; any already-tracked one escalated as a leak, not tidied away.
- [ ] Commits are logical units in conventional format; pushed, or the exact blocked command parked.
- [ ] Session/retro review done; each finding routed through the knowledge pipeline; unavailable channels recorded as not-run.
- [ ] Coherence test answered honestly; fixes made inside authority, the rest flagged.
- [ ] Orientation files current and still an index; bilingual mirrors moved together.
- [ ] Skills audited against the canon-craft floor; merges and prunes proposed, not landed under `supervised`.
- [ ] Whole-repo working-file scan complete.
- [ ] Report written on all four axes; unresolved decisions parked under `## Awaiting operator`.
- [ ] Repo gates green at exit; state files match the code.

A pass is **not done** until this checklist passes and `the-boss`'s Workspace-clean DoD is satisfied.

## Wiring

- **Owner:** `continuous-improvement-lead` — owns the cadence and runs the pass. Owning both this canon and the improvement loop is deliberate: the same role holds the seam between them, so neither drifts into the other.
- **Applying class:** `the-boss` (the workspace-clean line in sign-off), `devops-platform-engineer` (git mechanics, remotes, ignore rules, push paths), `technical-writer` (steps 3 and 5 — knowledge distillation and orientation files), `roster-maintainer` and `agent-optimizer` (step 6's skills audit on the SAEED repo, under the AUTONOMY rules above).
- **Gate:** `the-boss`'s Workspace-clean DoD (the workspace half of the same truth standard as its State-file-truth DoD). A red verdict blocks per the precedence order in `skills/self-governance/SKILL.md`; where verdicts conflict, the stricter wins.
- **Mechanical floor:** a clean `git status`, the repo's own gates green (`scripts/validate-fleet.sh` at exit 0 on the SAEED repo), and one heartbeat line in `.saeed/retro.md`. All three are checkable without reading a report.
- **Deliberate exclusions.** Builders and reviewers are **not** in the applying class: housekeeping adds no per-change obligation, and wiring it into every engineer would manufacture exactly the gate overhead the ladder exists to prevent. The drift check lives **only** here — the disaster-recovery runbook in `skills/self-governance/SKILL.md` triggers on *broken* state, while this is routine hygiene; one rule, one home. External-channel review carries no owner because it has no connector; when one is configured, it inherits step 3 rather than becoming a new rule.

## Attribution

This canon distills, with gratitude, mikesol's **`repository-housekeeping`** skill for cc-disco (distributed via mcpmarket) — the eight-step pass, the commit-over-delete default and its "git history is cheap, lost knowledge is not" reasoning, the local-customizations-win conflict rule, the three distillation questions, and the fresh-eyes coherence test. Its Discord-specific channel review, cc-disco directory assumptions, and ask-the-user setup step are replaced here by connector-conditional review, whole-repo scanning, and the house handover ladder. When that skill is installed, prefer invoking it for full depth; this file guarantees the standard when it is not.
