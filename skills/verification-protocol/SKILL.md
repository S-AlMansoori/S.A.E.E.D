---
name: verification-protocol
description: SAEED's evidence-and-verification canon (absorbed from the ECC / Everything Claude Code methodology). Consult whenever work is about to be declared done, reviewed, or shipped — it defines the ordered executable gates, the RED-gate TDD rule, the Verification Report format, pass@k vs pass^k thresholds, and the anti-noise review doctrine that code-reviewer, qa-automation-engineer, test-architect, self-eval-critic, and the-boss all enforce.
---

# SAEED Verification Protocol (verification over vibes)

Absorbed and adapted from the ECC ("Everything Claude Code") verification-loop,
tdd-workflow, and eval-harness canons. The one-line doctrine: **a claim of
"done" is worth exactly the evidence attached to it.** Prose confidence is not
evidence; an executed gate is.

This protocol binds every agent. `the-boss` refuses sign-off without a
Verification Report; `self-eval-critic` re-runs the gates independently.

## The ordered gates (run in order, hard stop on failure)

Run after any feature/refactor and before anything is declared DONE:

1. **Build** — the project compiles/bundles. If this fails, STOP: fix before
   running anything else (later gates on a broken build are noise).
2. **Types** — the type checker passes (`tsc --noEmit`, `mypy`, etc.).
3. **Lint** — the linter passes *with the existing config*. Editing the
   config to get past this gate is gate-weakening — a self-governance
   untouchable, and mechanically blocked by the plugin's
   `guard-config-protection` hook.
4. **Tests** — the full suite passes; coverage on changed code meets the
   repo's threshold (default 80% if the repo has none).
5. **Security scan** — no secrets in the diff (keys, tokens, credentials),
   no new injection surface on user input, deps clean per the repo's audit
   tool. Findings here are Critical by default (see `skills/agentic-security/SKILL.md`).
6. **Diff review** — read the full diff once more as a reviewer, not an
   author: dead code, debug output, unintended files, doc-comment honesty.

On the SAEED plugin repo itself, gate 4's equivalent is
`scripts/validate-fleet.sh` — it must exit 0.

## The Verification Report (fixed format)

Every verification pass ends in this report — in the ticket, the queue item,
or the reply; for durable evidence append it to `.saeed/retro.md`:

```text
VERIFICATION REPORT — <item id / description>
Build:     PASS | FAIL | N/A (<command used>)
Types:     PASS | FAIL | N/A
Lint:      PASS | FAIL | N/A
Tests:     PASS | FAIL — <n passed / n failed, coverage %>
Security:  PASS | FAIL — <scan performed>
Diff:      PASS | FAIL — <files reviewed>
VERDICT:   READY | NOT READY (<one-line reason>)
```

No READY, no sign-off. A NOT READY report with named failures is a *good*
outcome — it is the loop working.

## The RED gate (TDD, when tests lead)

When work is test-driven (the default for new behavior, per
`qa-automation-engineer` / `test-architect`):

- A test only counts as **RED if it was executed and failed for the intended
  business reason** — written-but-never-run does not count, and neither does
  failing on an import error. Do not touch production code until RED is
  confirmed.
- Checkpoint the trail in git: a `test:` commit for RED, the implementing
  commit for GREEN, an optional `refactor:` commit after. The history *is*
  the evidence.
- Fix the implementation, not the test — unless the test is provably wrong,
  and then say so in the commit message.

## Evals for AI-facing work (pass@k vs pass^k)

For LLM/RAG/agent features (`llm-engineer`, `rag-architect`, `ml-engineer`):

- **Define evals before building.** An AI feature without an eval is a vibe.
- Prefer **code graders** (deterministic) over model graders (LLM-as-judge,
  for open-ended output only). **Security-relevant checks always keep a
  human grader** — never fully automate them.
- Thresholds: capability evals pass@k (any of k runs succeeds), e.g.
  `pass@3 ≥ 0.90`; release-critical regressions **pass^k (all k runs
  succeed)** — `pass^3 = 1.00` before merge. Consistency, not luck.
- Version the eval set and baseline next to the code; re-run on model swaps
  (`model-scout` upgrades included).

## Anti-noise review doctrine (for the reviewing agents)

A review gate that cries wolf gets ignored, which is worse than no gate.
`code-reviewer`, `design-reviewer`, and `self-eval-critic`:

- Report a finding only when **>80% confident** it is real.
- Pass the four-question pre-report gate: (1) can you cite the exact
  file:line? (2) can you name a concrete failure scenario — inputs/state →
  wrong outcome? (3) did you read the surrounding context, not just the
  hunk? (4) is the severity defensible?
- **HIGH/CRITICAL findings require proof** — a reproduction, a failing
  input, or a cited spec violation. "This looks unsafe" is a Suggestion,
  not a Critical.
- Severity gates the verdict: Critical/High block; Medium/Low ship with
  notes.

## Continuous mode

Verification is not a finale. Re-run the relevant gates after each component
lands (cheap gates every time, the full ladder before DONE) so a regression
is caught one step after it appears, not at the end of the pass. This is the
per-item version of the improvement loop's convergence check.

## E2E verification (browser evidence, when the deliverable is a web app)

Absorbed and modernized from `anthropic-skills:webapp-testing`. The one-line
doctrine: a UI claim is "verified" only when a browser actually drove it and
left evidence behind — a screenshot, a captured console log, a passing
web-first assertion. Reading the code and reasoning about what it "should"
do is not evidence.

**Decision tree — choose the approach before touching a selector:**

1. **Static HTML** → read the file directly to find selectors, then write
   the Playwright script. If reading falls short (templated/partial markup),
   treat it as dynamic instead.
2. **Dynamic app, server not running** → stand it up through a
   **server-lifecycle harness**: N servers started, each readiness confirmed
   by polling its port (never a fixed sleep), the command run, and
   **guaranteed teardown** (terminate, then kill on timeout) in a `finally`
   block regardless of outcome. The automation script itself contains only
   Playwright logic — starting and stopping servers is the harness's job,
   not the script's.
3. **Dynamic app, server already running** → **reconnaissance-then-action**:
   navigate, then inspect (screenshot, DOM query, element enumeration)
   before writing a single action. Never guess a selector for JS-rendered UI.

**Non-negotiables:**

- **Headless Chromium, always** — launch with `headless=True`; close the
  browser when done.
- **Console evidence is pre-navigation.** Register the `page.on('console',
  …)` handler **before** `page.goto(...)`, not after — a handler attached
  post-navigation misses everything the page logs on load. Persist the
  captured console lines as an evidence artifact alongside the screenshot,
  not just as terminal scrollback.
- **Element-discovery inventory.** Recon enumerates the interactive surface
  — buttons, `a[href]` links, inputs/textareas/selects — as a named/role/type
  list before any selector is chosen, never after a failed guess.

**Modernized waits (SAEED departs from the source here):**

- `networkidle` is **recon-only** — a pragmatic way to let an unfamiliar app
  settle before you inspect it. It is **never** the assertion mechanism: do
  not gate a test's pass/fail on `wait_for_load_state('networkidle')`. Use
  web-first assertions and auto-waiting locators that retry until the real
  condition is true, not a network-quiescence proxy for it.
- `wait_for_timeout` (a fixed sleep) is **banned** — it is the canonical
  flaky-test smell: too short and it races the app, too long and it wastes
  the run. Replace every instance with a condition-based wait.

**Evidence maps into the existing report, unchanged.** A browser-verified
web claim satisfies the Verification Report's **Tests** row (state what
Playwright exercised and what it captured); for a non-UI deliverable that
row reads **N/A** with the reason. No new row, no format change — the
report's consumers read what's already there.

Bundled automation belongs to `anthropic-skills:webapp-testing`'s helper
scripts (e.g. its server-lifecycle runner) when installed — invoke them as
black boxes (`--help` first; read the source only if a customized solution
is genuinely unavoidable) — or write native Playwright otherwise. **Never
let a missing plugin lower the bar** — the decision tree, the harness
pattern, and the modernized-waits rule apply either way.

## Doc-delivery cold-reader gate

Absorbed from Anthropic's `doc-coauthoring` reader-testing stage. The
one-line doctrine: **"done" for a document means a context-free reader
actually understood it** — the author's own re-read does not count as
evidence.

**Scope.** Doc *deliverables* — specs, READMEs, operator/runbook docs, user
guides; not code comments, changelog entries, or internal tickets (the
task-size ladder's does-not-apply line for this gate).

**Before drafting** — the context checklist: doc type, primary audience,
desired impact on the reader, format/template, org context, and
why-not-alternatives. Structure the doc with the highest-uncertainty
section (the core decision or technical approach) first; summaries last.

**The gate itself**, looped until it passes:

1. Predict 5-10 questions a real reader would ask when discovering this doc.
2. Hand the finished (or near-finished) doc text to a **context-free
   subagent** — no session history, just the document — and put each
   predicted question to it in turn; record right/wrong per question.
3. Run three standing checks on the same context-free subagent: ambiguity
   ("what here could be read more than one way?"), assumed knowledge ("what
   does this doc assume the reader already knows?"), and internal
   contradictions.
4. Any wrong answer, surfaced ambiguity, or contradiction sends the
   affected section back for a rewrite, then re-runs steps 2-3 on the
   revised text — loop until the cold reader answers cleanly and raises no
   new gaps.
5. At ~80% complete, one full read-through of the whole doc (not per
   section) for flow, redundancy, contradictions across sections, and
   generic filler ("slop") that carries no weight.
6. Every image ships with alt-text; an unlabelled image fails the gate.

**Bilingual extension.** AR and EN are gated **separately, with independent
cold readers**: run the full predicted-question loop once against the
English text and once against the Arabic text, each with its own
predicted-question set (a question an English reader asks is not
necessarily the one an Arabic-native reader asks) and its own cold-reader
subagent. Passing the EN cold-reader loop is not evidence for AR, and the
AR pass also checks native register and correct RTL rendering, not just
comprehension.

**What is deliberately dropped.** The source's human-facilitation
choreography — the info-dump prompts, the section-by-section
brainstorm/curation dialogue, the multi-stage negotiation with a human
co-author — is not absorbed; SAEED runs the cold-reader gate as an
automated verification step a subagent executes, not a live collaborative
workflow.

**Reporting.** A doc pass records its cold-reader verdict in the
Verification Report's existing `Diff` row (e.g. `Diff: PASS — 8/8
predicted questions answered correctly, EN + AR cold-reader pass`) or as
`N/A` when the change carries no doc deliverable — the report format
itself is unchanged.

**Invoke the deep skill.** `anthropic-skills:doc-coauthoring` for the full
interactive co-authoring workflow when installed — its Context Gathering /
Refinement stages remain useful for drafting even though this canon absorbs
only its Reader Testing stage as a gate. **Never let a missing plugin lower
the bar**: the cold-reader loop above runs identically with or without it.

## Wiring

- `the-boss` — sign-off consumes the Verification Report; READY required.
- `code-reviewer` / `design-reviewer` — anti-noise doctrine governs findings.
- `qa-automation-engineer` / `test-architect` — RED gate, coverage, pass^k.
- `self-eval-critic` — independently re-runs gates; a verdict without a
  report is itself a finding.
- `/saeed:verify` — the on-demand command that runs this protocol end to end.
