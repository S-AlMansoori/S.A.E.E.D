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

## Wiring

- `the-boss` — sign-off consumes the Verification Report; READY required.
- `code-reviewer` / `design-reviewer` — anti-noise doctrine governs findings.
- `qa-automation-engineer` / `test-architect` — RED gate, coverage, pass^k.
- `self-eval-critic` — independently re-runs gates; a verdict without a
  report is itself a finding.
- `/saeed:verify` — the on-demand command that runs this protocol end to end.
