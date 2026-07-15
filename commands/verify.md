---
description: Run SAEED's Verification Protocol on the current project — execute the ordered gates (build, types, lint, tests, security, diff) and return an evidence-backed READY / NOT READY report. Verification over vibes.
argument-hint: [optional: a specific change, item id, or path to verify]
---

Run SAEED's Verification Protocol (`skills/verification-protocol/SKILL.md`) on this repository. Scope: $ARGUMENTS — if empty, verify the current working tree's pending changes (or, with a clean tree, the repo's overall gate health).

1. **Detect the stack** from the repo's own files (package.json scripts, pyproject.toml, Makefile, CI config) — never assume a runner. State which commands you chose and why.
2. **Run the ordered gates, hard stop on failure**: Build → Types → Lint → Tests (with coverage on changed code) → Security scan (secrets in the diff, injection surface, dependency audit) → Diff review (read the full diff as a reviewer: dead code, debug output, unintended files, doc-comment honesty). Do not "fix and claim" — if you fix something, re-run the gate that caught it.
3. **On the SAEED plugin repo itself**, also run `scripts/validate-fleet.sh` as the Tests gate — it must exit 0.
4. **Report** using the fixed Verification Report format from the skill: one PASS/FAIL line per gate with the command used and the evidence (counts, coverage, findings), ending in an explicit `VERDICT: READY` or `VERDICT: NOT READY (<reason>)`. If `.saeed/` exists, append the report to `.saeed/retro.md`.

Findings follow the anti-noise doctrine: only >80%-confident findings, exact file:line, a concrete failure scenario, and proof for anything HIGH/CRITICAL. Delegate deep dives where warranted — `code-reviewer` for the diff gate, `appsec-engineer` for security findings (per `skills/agentic-security/SKILL.md`) — but the report and verdict come back consolidated, and a red gate is never argued away in prose.
