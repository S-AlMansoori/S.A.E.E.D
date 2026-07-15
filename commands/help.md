---
description: Show the SAEED cheat sheet — every command, what it does, and when to use it.
---

Show the user the SAEED cheat sheet in clear, friendly language. Present it as a compact table of the commands below, then the one-liner on autonomous mode. Don't overexplain.

- `/saeed:hire <goal or spec>` — The big one. Hands the team a project to take from zero to done (design → build → test → secure → document) and then improve on its own. Use this to start almost anything.
- `/saeed:improve` — Run improvement passes on the current project (audit → fix the highest-value things → verify → repeat). Use this whenever you want it to get better. This is the self-improvement button.
- `/saeed:verify` — Run the Verification Protocol: the ordered gates (build → types → lint → tests → security → diff) with an evidence-backed READY / NOT READY verdict. Use before a merge or handover, or whenever you want proof instead of promises.
- `/saeed:status` — A blunt status report from the Boss on what's done, in progress, blocked, or rejected. Use before a review or when you're unsure where things stand.
- `/saeed:upgrade` — The team upgrades itself: switches to better AI models when available and adds/improves/retires its own agents. Use every so often, or when a stronger model ships.
- `/saeed:stop` — Halt the autonomous loop (creates a `.saeed/STOP` file). Resume by deleting it and running `/saeed:improve`.
- `/saeed:help` — Show this cheat sheet.

Also mention: you don't have to use commands at all — you can just ask in plain English (e.g. "use the rag-architect to design retrieval for this") and the right specialist is picked automatically. For hands-off, always-on improvement, point `scripts/saeed-loop.sh /path/to/repo` at a project and it runs passes until the work converges or you stop it. Full details live in `docs/CHEATSHEET.md` and `docs/WHAT-IS-SAEED.md` (English + Arabic).
