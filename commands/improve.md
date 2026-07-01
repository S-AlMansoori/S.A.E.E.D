---
description: Run improvement passes on the current project — audit, fix the highest-value things, verify, repeat. This is the self-improvement button.
---

Run SAEED improvement passes on this repository (this is the easy, repeatable self-improvement step — run it as often as you like).

First check stop conditions: if `.saeed/STOP` exists, do nothing and say the loop is halted. If `.saeed/CONVERGED` exists, say the project has already converged and ask whether to override.

Otherwise, for each pass:

1. `continuous-improvement-lead` subagent → audit across correctness, security, performance, accessibility, i18n/RTL, design excellence (anti-AI-slop craft, per `skills/design-excellence/SKILL.md`), tests, docs, DX, and cost; write the top items (with measurable acceptance criteria) to `.saeed/queue.md`.
2. `the-boss` subagent → assign each item to the right specialist and hold the Definition of Done — including the handover check (`skills/handover-protocol/SKILL.md`): a fix that ends in a manual user step that Claude could have automated or handed to Cowork is not done.
3. Specialists implement their items.
4. `code-reviewer` subagent + `qa-automation-engineer` tests gate every change; user-facing changes also pass the `design-reviewer` (Design Excellence) gate.
5. `self-eval-critic` subagent → independently verify the gains, catch regressions, and append a retro to `.saeed/retro.md`.
6. `the-boss` subagent → update `.saeed/state.json` and give a short standup of what changed.

Run several passes until returns clearly diminish. When a full audit finds nothing above the value threshold, `continuous-improvement-lead` writes `.saeed/CONVERGED` with evidence and you stop. Every few passes, also run `/saeed:upgrade` so the team keeps itself current.
