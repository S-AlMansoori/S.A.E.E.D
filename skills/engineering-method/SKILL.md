---
name: engineering-method
description: SAEED's absorbed engineering-method canon — the TDD Iron Law with its rationalization counters and adjudication rules, four-phase systematic debugging, the brainstorm gate before implementation, the zero-context plan law, subagent-controller mechanics, and the task-size applicability ladder that scopes every SAEED gate. Binds every builder and controller automatically on any code change.
---

# SAEED Engineering Method — the absorbed canon

SAEED has absorbed obra's **Superpowers** (test-driven-development, systematic-debugging, brainstorming, writing-plans, subagent-driven-development) and nizos' **TDD Guard / Probity** (the validation rules an AI TDD gate enforces, and the adjudication nuance that keeps it from crying wolf). Their combined lesson: **quality comes from method, not from reviewer heroics after the fact.** This file is that method — every builder and controller applies it automatically, on any code change, without being asked.

## Scope — and the applicability ladder (the single home)

Binds automatically: the nine builder engineers, `team-orchestrator` and `the-boss` as controllers, `principal-architect` for design approval, `qa-automation-engineer`, and `code-reviewer` re-deriving every diff against it. It never decides *whether* to apply — the class-wide wiring already decided that; it decides **how much ceremony a given task has earned**, via the ladder below.

**This ladder is defined exactly once, here.** Every canon, agent, and command that scopes its own gates by task size references it by this path rather than carrying its own tiers. A referrer may name the tier letters and say what binds at each — that is the point of referencing — but the *triggers* that classify a task live only here, so there is one place to change when they change.

**Does NOT apply:** work that ships no code — a design note, a spec, a doc-only or ledger-only change. The ladder classifies code changes; a canon-authoring or bookkeeping pass answers to its own gates, not to this one.

Three tiers, objective triggers — declare the tier in the ticket/brief; `code-reviewer` re-derives it from the diff on every review:

- **S — trivial/mechanical.** No behaviour change: typo, rename, doc line, config value, single-file cosmetic fix. **Binds:** the cheap executable gates (build/lint/tests stay green) + diff review. **Exempt:** the brainstorm gate, plan law, TDD ceremony (no new behaviour ⇒ no new test), and every other canon's heavier gates. This is the anti-regress guarantee — a one-line fix meets at most what it met the release before.
- **M — standard change.** New behaviour or a bug fix, one module, no contract or security-surface change. **Binds:** the TDD Iron Law (a bug fix starts with a failing repro test); systematic debugging from the second failed attempt; a *lightweight* brainstorm (a written approach note in the ticket, not a Socratic session); the normal review gates. **Exempt:** the brainstorm HARD-GATE's full session, plan law (unless delegated).
- **L — feature/multi-module/architectural/security-touching.** Any of: crosses a module or contract boundary; touches auth, input, secrets, money, or the network boundary; spans more than five files or one session; enters `hire.md` Phase 1 or an orchestrated wave. **Binds everything below** plus every other canon's full-depth gate.

**Tier rules:** security-touching work can never take the S path. **Escalate on doubt or growth** — a task that outgrows its tier mid-flight stops and re-enters at the higher tier. Misdeclaring a tier to dodge a gate — like skipping one that binds — **is gate-weakening**, `skills/self-governance/SKILL.md`'s untouchable #1, not a shortcut.

Applied to this canon's own gates specifically:
- **TDD Iron Law** — binds at M and L (new behaviour, bug fixes); exempt at S, for deletions, characterization tests, refactor-under-green, and labelled throwaway spikes (which never ship without tests).
- **Systematic debugging** — binds from the second failed fix attempt or any non-obvious bug at any tier above S; a first-attempt obvious fix is exempt.
- **Brainstorm HARD-GATE** — full at L; a lightweight note at M; exempt at S and whenever an approved design/ADR already covers the change (the gate is design *approval*, not design *repetition*).
- **Plan law** — only when a plan is handed to someone else (delegation/orchestration); solo same-session work is exempt.

Every other canon's own does-not-apply line uses this same ladder and this same vocabulary — cross-referenced, never copied.

## Invoke the deep skills (when the Skill tool is available to you)

| Task in front of you | Invoke |
|---|---|
| TDD, debugging, design approval, plans, subagent dispatch | `superpowers` (obra) |
| An AI TDD validator with adjudication nuance | `tdd-guard` / `probity` (nizos) — rules text absorbed below; the npm package is never installed |

If none are installed, the canon below still fully applies. Never let a missing plugin lower the bar.

## (1) The TDD Iron Law

```
NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST
```

RED — write one test for one behaviour, **watch it fail for the right reason** (an assertion, never an import/syntax error); GREEN — the minimum code that makes it pass, nothing anticipatory; REFACTOR — clean up only once green, no new behaviour smuggled in. Code written before its test is deleted, not kept "as reference" — you'll adapt it, which is testing-after with extra steps.

**The revert-the-fix red-green proof**, absorbed from Superpowers' verification-before-completion (excluded elsewhere per the research ruling, this one delta kept): a regression test only proves the bug is caught when you run it, revert the fix, watch it **fail**, then restore the fix and watch it pass again. A test that merely passes once proves nothing about what it catches. Cross-ref: `skills/verification-protocol/SKILL.md`'s RED gate carries the git-checkpoint form of this same proof — text there is unchanged.

**Rationalization counters** — the excuse, and why it doesn't hold:

| Excuse | Reality |
|---|---|
| "Too simple to test" | Simple code breaks; the test costs 30 seconds. |
| "I'll test after" | A test written after passes immediately — that proves nothing; you never watched it fail. |
| "Tests after achieve the same goal" | Tests-first answer "what *should* this do?"; tests-after only answer "what does this do?", biased by the code you already wrote. |
| "Already manually tested" | Manual testing leaves no record and doesn't re-run on the next change. |
| "Deleting hours of work is wasteful" | Sunk cost — the time is spent either way; keeping untested code is the real waste. |
| "Keep it as reference while writing tests" | You'll adapt it. That's testing-after. Delete means delete. |
| "Need to explore first" | Fine — throw the exploration away, then start with TDD. |
| "Hard to test" | Hard-to-test means hard-to-use; listen to the test, simplify the design. |
| "TDD will slow me down" | TDD is the pragmatic path — the alternative is debugging in production. |
| "Manual test is faster" | It doesn't prove edge cases and you re-run it by hand every change. |
| "Existing code has no tests" | You're touching it now; add tests for what you touch. |

**Red flags — stop and start over:** code before test, test passes immediately, "I already manually tested it," "it's about spirit not ritual," "already spent hours, deleting is wasteful," "this is different because…" All of these mean: delete the code, start over with TDD.

## (2) Four-phase systematic debugging

```
NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST
```

1. **Root cause investigation** — read the full error/stack trace, reproduce reliably, check recent changes, and in multi-component systems add diagnostic instrumentation at each boundary *before* guessing which layer broke. Trace bad values backward through the call stack to their origin; fix at the source, not the symptom.
2. **Pattern analysis** — find a working example nearby, read any reference implementation completely (not skimmed), list every difference, however small.
3. **Hypothesis and testing** — state one hypothesis in writing, change the smallest possible thing to test it, verify before touching anything else. Don't know? Say so; don't guess.
4. **Implementation** — write the failing repro test first (this phase feeds the TDD Iron Law above), make the single fix the hypothesis predicts, verify.

**The 3-fix architecture rule.** If a fix doesn't work: under 3 attempts, return to Phase 1 with the new information. **At 3 or more failed fixes, stop and question the architecture** — this is no longer a failed hypothesis, it is a wrong design. Each fix revealing a *new* problem elsewhere, or requiring "massive refactoring," is the tell. Escalate the architectural question rather than attempting fix #4.

**Rationalization counters:** "emergency, no time for process" — systematic debugging is faster than guess-and-check thrashing; "just try this and see" — the first fix sets the pattern, do it right; "I see the problem, let me fix it" — seeing a symptom is not understanding a root cause; "one more attempt" after two failures — that's the architecture question, not a fresh hypothesis.

## (3) The brainstorm HARD-GATE

Socratic design approval before any implementation action, scoped by the ladder above (full at L, a lightweight note at M, exempt at S or when an approved design/ADR already covers the change). Explore context, ask clarifying questions one at a time, propose 2–3 approaches with a recommendation, present the design in sections scaled to complexity, get approval **before** invoking any implementation skill. "Too simple to need a design" is the anti-pattern the gate exists to catch — the smallest utility function has hidden assumptions too; the design can be one sentence, but it must still be presented and approved.

## (4) The plan law (zero-context engineer assumption)

Write every delegated plan **as if the engineer executing it has zero context for the codebase**: name exact files to create/modify (with line ranges for edits), give each task a `Consumes:` block (exact signatures it relies on from earlier tasks) and a `Produces:` block (exact names and types later tasks will use), and write the actual code/values inline — never a placeholder. Banned phrases that make a plan undeliverable: "TBD", "add appropriate error handling", "similar to Task N" (repeat the code; the engineer may read tasks out of order), any type or function referenced in no task. Scoped by the ladder: plan law binds only when the plan is handed to someone else (delegation, orchestration); solo same-session work is exempt.

## (5) Subagent-controller mechanics

A controller runs its subagents under this same method — the concrete mechanics (the compaction-proof progress **ledger**, the capped **fix-loop** at five rounds with model-tier escalation on rounds 4–5, file-path-not-paste dispatch hygiene, and model-tier economics) are documented once, in `skills/orchestration-protocol/SKILL.md` ("Controller mechanics" section) — cross-referenced here, not restated, per the same one-home-per-rule rule this canon states everywhere else.

What belongs here instead is the discipline the ledger and fix-loop exist to *serve*: every review dispatched under this section re-derives judgment against the TDD Iron Law and the rationalization counters above, not against a prior verdict. **Never trust a subagent's self-declared "done"** — absorbed from Superpowers' verification-before-completion: a report of success is checked against the actual VCS diff and a fresh gate run, never accepted on prose alone (cross-ref: `skills/verification-protocol/SKILL.md`'s Verification Report is the evidence a controller demands before closing a task). Every dropped or parked finding gets a written adjudication line in the ledger — a silent discard is forbidden at any round.

## TDD adjudication rules (absorbed from Probity)

These are the nuances that keep a TDD gate — human or AI — from crying wolf on structurally-transient but ultimately-compliant work:

- **A transient broken state is never itself a violation** — an unresolved symbol, a dead reference, a half-finished multi-step change. Judge the *change* a write makes, not whether the file runs at that instant; that's what the next test run checks, not the reviewer.
- **Deletion never needs a failing test** — removing code, tests, or helpers is always allowed, even when the removed code was used or covered.
- **Characterization tests may pass immediately** — a test pinning existing behaviour (before a refactor, or covering a new layer over already-tested code) is not required to fail first; only tests driving *new* behaviour are.
- **Clean-red recovery taxonomy** — a test can fail before reaching its assertion. Import/symbol unresolved → a placeholder stub only (a body that makes the symbol exist without implementing the asserted behaviour). Signature mismatch → adjust the signature, keep the stub. Assertion failure → now implement the minimal logic. A stub that returns a literal the assertion will reject is still a valid stub; implementing the asserted behaviour at this step is not.
- **Intent-based one-new-test counting** — compare old content to new; only a test that did not exist before counts as "new." Restructuring, renaming, splitting, or combining existing tests is not "adding," even bundled with one genuinely new test. One new test per write is the rule; the total test count in the file is irrelevant.
- **Refactor-under-green allowances** — with relevant tests passing, adding types/interfaces/constants (no runtime behaviour by construction) or extracting helpers whose behaviour already lives elsewhere is always allowed without a new test. A helper whose behaviour appears nowhere else is net-new and needs a failing test first.
- **A high bar for forcing a refactor** — starting the next test crosses the green-to-red boundary, so a validator may check whether the prior green left an unmistakable, downside-free refactor undone — but the bar is high, because forcing one risks needless abstraction the agent could see and the validator cannot. When the win isn't clear-cut, let green stand.

## Validator conduct

Whoever adjudicates TDD compliance — `code-reviewer` on a diff, or the mechanical hook below — follows the same conduct rules (wired into `agents/code-reviewer.md`):

- **Re-derive judgment fresh.** A block recorded earlier in the session is a past verdict, not a rule; never block a new attempt only because a prior one was blocked.
- **Explicit operator override is authoritative** — identical, on purpose, to `skills/self-governance/SKILL.md`'s precedence level 1 (the operator overrides everything, mid-cycle). The override is for this instance; lasting changes go through the canon or the sentinel, never a standing exception.
- **Name the violation without dictating edit order.** Say what broke TDD and why; never require the file be complete or runnable, or bundle unrelated steps into the same write.

A red verdict here blocks like any other gate (`skills/self-governance/SKILL.md` precedence level 3, red-gate supremacy); the exits are fix-it or a domain-owner `WONTFIX`, logged. Conflicting verdicts (e.g. a TDD "violation" against `code-reviewer`'s "approve") resolve by the same file's stricter-verdict rule (precedence level 5) — no new arbitration machinery.

## The `.saeed/TDD` sentinel (the mechanical floor, where a repo opts in)

`hooks/guard-tdd-mode.sh` is the deterministic bash approximation of the adjudication above — not a replacement for it. A per-repo `.saeed/TDD` file, first non-blank/non-`#` line one of `off` | `advisory` | `enforce`:

- **Absent (the default everywhere)** → silent, zero overhead; a repo must opt in.
- **`off`** → same as absent.
- **`advisory`** → the two deterministic detections (a shell bypass-channel write into logic-bearing source; a source edit with no test file in the change-set) warn on stderr and pass; sentinel-tamper still blocks — an active guard, even advisory, cannot be weakened.
- **`enforce`** → both detections block; sentinel-tamper blocks.
- **Unparseable sentinel or payload** → fail open, house pattern.

The hook judges deterministic proxies only (a bypass write, a missing test file in the change-set); it never judges the adjudication nuance above — transient states, characterization tests, refactor-under-green — that stays canon and reviewer territory.

## Wiring

- **Owner:** `test-architect` — method steward.
- **Applying class:** the nine builders (`backend-engineer`, `frontend-engineer`, `python-engineer`, `typescript-specialist`, `ios-engineer`, `android-engineer`, `macos-engineer`, `react-native-engineer`, `edge-serverless-engineer`); `team-orchestrator` + `the-boss` (controller/ledger/fix-loop); `principal-architect` (brainstorm gate, plan law); `qa-automation-engineer`; `code-reviewer` (validator conduct, rationalization counters, tier plausibility).
- **Deliberate exclusion:** the other coding specialists (`data-engineer`, `realtime-engineer`, `ml-engineer`, `llm-engineer`, `ai-systems-engineer`, `mlops-engineer`, and similar) do **not** self-carry this canon — they inherit it through the gates (`code-reviewer` + the RED gate) exactly as `skills/self-governance/SKILL.md` scopes non-governance specialists out of governance doctrine. They never ship code without a carrying gate in the loop.
- **Gate:** `code-reviewer` on every diff, plus the verification-protocol RED gate; the `.saeed/TDD` sentinel is the mechanical floor where a repo enables it.

## Attribution

This canon distills, with gratitude, obra's **Superpowers** (`test-driven-development`, `systematic-debugging`, `brainstorming`, `writing-plans`, `subagent-driven-development`, and the `verification-before-completion` deltas named above) and nizos' **TDD Guard / Probity** (the validation rules and the adjudication/validator-conduct doctrine). When those plugins are installed, prefer invoking them for full depth; this file guarantees the standard when they are not.
