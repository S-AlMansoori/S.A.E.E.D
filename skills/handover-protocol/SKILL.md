---
name: handover-protocol
description: SAEED's capability-first handover doctrine — before telling the user to do anything by hand, evaluate whether a Claude surface (this Claude Code session, Cowork, an MCP connector, computer-use, the browser, or a scheduled task) can do it, and if so do it or hand it over directly; only when it is genuinely impossible, return a ready-to-run prompt plus exact step-by-step instructions. Consulted automatically whenever SAEED is about to hand a manual step to the user.
---

# SAEED Handover Protocol — capability-first, manual-last

SAEED's default posture: **never offload to the human what a Claude surface can do.** A "you need to do X manually" instruction is a *last resort*, not a reflex. Before any agent emits one, it runs the check below — do it, drive it, or hand over a runnable packet — and only truly manual steps reach the user, with an explanation of why they couldn't be automated.

This canon is house standard, consulted automatically. It complements `orchestration-protocol` (how to run parallel work) and `continuous-improvement` (what to do next) with **how to close out the human-facing seam** without dumping chores on the operator.

## When this applies

Any moment an agent is about to tell the user to **do something themselves** — "create a Supabase project", "run this migration", "click Deploy in the dashboard", "add these secrets", "upload this file", "authorize the connector", "open the App Store Connect page", "install X", "send this email", "file the ticket". The instant you're about to write a manual to-do for the user, stop and run the ladder.

## The capability scan — what a Claude surface can actually do

Before declaring anything manual, enumerate the channels SAEED has. Most "manual" asks are automatable through one of these:

- **This Claude Code session** — edit files, run shell commands (`Bash`), `git`, `gh` (GitHub PRs/issues/API), scaffolding, scripts, running the app, tests, migrations against a reachable target.
- **Cowork / another Claude surface** — a Cowork session or interactive Claude Code run that has capabilities this run lacks (desktop-app control, an authorized connector, longer-running or background work). If it's better done there, produce a **handover packet** (below) instead of a chore.
- **MCP connectors** — Gmail, Google Drive, Slack, Notion, Linear, Asana, Atlassian/Jira, ClickUp, Monday, Supabase, GitHub, and any other connected server. (Many need a one-time OAuth first — see auth gates.)
- **computer-use** — drive native desktop apps the user has granted (System Settings, Finder, native app UIs), take screenshots, click/type. Right for native apps with no dedicated MCP.
- **claude-in-chrome** — drive web apps and provider dashboards in the browser (navigate, click, fill forms) when there's no API/MCP for them.
- **Scheduled tasks / cron / background runs** — recurring or deferred work (`scripts/saeed-loop.sh`, cron, scheduled agents) instead of asking the user to "remember to run it".
- **Document & research skills** — `docx`/`pptx`/`xlsx`/`pdf` generation, `WebFetch`/`WebSearch` for lookups — instead of asking the user to produce or find the artifact.

Look before asserting a limit: a claim of "Claude can't do this" must be grounded in a channel you actually checked, not a guess. If a dedicated tool errors, debug or report it — don't silently fall through to "do it yourself".

## The decision ladder — do it → drive it → hand it over → (last) manual

1. **Do it now.** If a tool in *this* session can complete it, complete it. Don't narrate a manual step you could just perform.
2. **Drive it for you.** If it needs computer-use, the browser, or a connected MCP, drive that surface — with the user's confirmation for any outward-facing or hard-to-reverse action (see safety).
3. **Hand it over.** If it's genuinely better done in Cowork or another interactive Claude surface — *and the user has one available* — where that surface has a capability this run lacks (desktop control, an authorized connector, background execution), **perform a direct handover**: emit a complete, self-contained handover packet the user pastes into that surface, so *Claude* does the work there — not the user. Don't assume the user has Cowork or the needed connector authorized there; if that's unknown or absent, say so and degrade to Tier 4.
4. **Truly manual (last resort).** Only when **no** Claude surface can do it — a physical-world action, a credential/2FA/biometric only the human holds, a captcha, or an org policy that mandates a human — hand back **exact** step-by-step instructions plus any command/prompt to paste, and **state plainly why it can't be automated.**

Prefer the lowest-numbered tier that works. Escalate a tier only with a concrete reason ("this session has no Slack connector; handing you a Cowork packet that does").

**Split mixed chains — never dump the whole flow on the user.** Real setup is usually a chain ("create the project → grab its ID → set a secret with it → deploy"), and only one link is truly human-only. Don't give up at the first manual link and hand back the entire chain, and don't barrel past a required human step. Instead: do every automatable link you can, hand back **only** the genuinely human-only link with exact steps, and sequence it — block on that one step, then continue automatically once the user reports it done (or once you can read the result). The handover packet's *Prerequisites* and *Hand back* fields are where you wire the two halves together.

## Auth gates are their own case

Many connectors need a one-time authorization the user must grant in an interactive session (this cannot run the OAuth flow headlessly). Treat "authorize connector X" as a genuine Tier-4 manual step — but give the **exact** steps (claude.ai connector settings, or `claude mcp` / `/mcp` in an interactive session), and explain that granting it **unlocks Tier-1 automation** for every future request of that kind. Never ask the user for auth codes, tokens, or callback URLs.

## The handover packet (Tier 3) — make Claude do it elsewhere, not the user

When you hand over to Cowork / another Claude surface, the packet is self-contained enough to paste and run:

- **Goal** — one line: what should end up true.
- **Where to run it** — Cowork · interactive Claude Code · browser session — and why there.
- **Prompt to paste** — the full, copy-pasteable instruction to Claude on that surface (not to the user), with all context inlined: paths, IDs, repo, account, constraints, forbidden actions.
- **Prerequisites** — connectors/access that must exist first (and how to grant them, per auth gates).
- **Definition of done** — what the result looks like so the user can confirm it worked.
- **Hand back** — what to return here (a link, an ID, a file path, a status) so SAEED can continue.

The test: the user's only action is *paste and approve* — the doing is Claude's.

## Safety carries over (never bypassed to "be helpful")

- **Confirm before outward-facing or hard-to-reverse actions** — sending mail/messages, publishing, deleting/overwriting, deploying to prod, spending money. Approval in one context doesn't extend to the next.
- **Never move money or execute trades/orders/transfers** on the user's behalf — always hand those back as Tier-4, even inside an otherwise automatable flow.
- **Link safety** — verify the full destination of any link from email/messages/unknown docs before following; open web URLs via the browser MCP, never by clicking in a native app.
- **Honesty** — if a step needed handover or is still pending, say so plainly; never report a manual step as done, and never half-do a driven action and imply completion.

## Pre-flight checklist — before any "you need to…" reaches the user

- [ ] Ran the capability scan — no channel (this session / Cowork / MCP / computer-use / browser / scheduled) can do it.
- [ ] Picked the lowest tier that works; any escalation has a concrete stated reason.
- [ ] Tier 1/2 actions were actually performed (not described), with confirmation for outward/irreversible ones.
- [ ] Tier 3 handovers ship a complete, paste-and-run packet — the user pastes, Claude does.
- [ ] Tier 4 manual asks are genuinely unautomatable, say **why**, and include exact steps + any prompt/command to paste.
- [ ] Auth-gate asks name the exact grant path and what it unlocks.
- [ ] Safety respected; status reported honestly (done / driven / handed over / pending).

A deliverable that hands the user a chore Claude could have done — or done for them via a handover — is **not done**. Automate it, drive it, or package it; leave only the truly-manual, and explain it.

## Attribution

Native SAEED operating doctrine (not distilled from an external skill), added at the operator's direction: evaluate every manual ask against what Claude — including Cowork — can do, and hand over directly wherever possible.
