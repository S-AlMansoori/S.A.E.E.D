---
description: Have the team upgrade ITSELF — move to better AI models when available and add, improve, or retire its own agents.
---

Run a SAEED self-upgrade. Because this changes the team itself, require the user's approval before writing edits unless they've explicitly said to self-modify autonomously.

1. `model-scout` subagent → check current Anthropic models (verify against official docs and real access status) and propose `model:` frontmatter changes across agents, recording old→new in `.saeed/models.md`. Never assign a model that isn't confirmed available and accessible.
2. `self-eval-critic` subagent → review `.saeed/retro.md` for recurring failures and capability gaps.
3. `agent-optimizer` subagent → sharpen the prompts/descriptions of any underperforming agents.
4. `roster-maintainer` subagent → add, merge, split, or retire agents where evidence justifies it, keeping scopes distinct and updating the README roster table.
5. Summarize the team changes (models changed, agents added/removed/edited) in plain language and, unless autonomous self-modification is enabled, wait for approval before the files are written.
