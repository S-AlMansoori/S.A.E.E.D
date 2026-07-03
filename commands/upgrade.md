---
description: Have the team upgrade ITSELF — move to better AI models when available and add, improve, or retire its own agents.
---

Run a SAEED self-upgrade. Because this changes the team itself, require the user's approval before writing edits unless they've explicitly said to self-modify autonomously.

1. `model-scout` subagent → check current Anthropic models (verify against official docs and real access status) and propose `model:` frontmatter changes across agents, recording old→new in `.saeed/models.md`. Never assign a model that isn't confirmed available and accessible. If a model needs the user to enable access or accept terms, apply the handover doctrine (`skills/handover-protocol/SKILL.md`): drive the console where possible, else hand back the exact steps as a genuine auth-gate — don't just tell the user to "go enable it".
2. `self-eval-critic` subagent → review `.saeed/retro.md` for recurring failures and capability gaps.
3. `hr-talent-lead` subagent → turn any confirmed capability gap into a hire decision + role brief (disjoint scope, reciprocal handoffs), and flag redundant or never-used agents for merge/retire.
4. `agent-optimizer` subagent → sharpen the prompts/descriptions of any underperforming agents.
5. `roster-maintainer` subagent → author, merge, split, or retire agents per the hire briefs and evidence, keeping scopes distinct and updating the README roster table.
6. Summarize the team changes (models changed, agents added/removed/edited) in plain language and, unless autonomous self-modification is enabled, wait for approval before the files are written.
7. Run `scripts/validate-fleet.sh` — the executable fleet-consistency gate. It must exit 0 before the upgrade is done: roster counts agree across the README badge/roster, `plugin.json`, `marketplace.json`, the EN+AR docs (incl. Arabic numerals and the SVG badge) and `.saeed/state.json`; every agent has valid `name`/`description`/`model` frontmatter with `name` matching its filename; the opus/sonnet tallies match `.saeed/models.md`; all manifests are valid JSON; and every `Handoffs` reference resolves. A red validator blocks the upgrade — never sign off over it.
