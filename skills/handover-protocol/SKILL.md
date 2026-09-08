---
name: handover-protocol
description: SAEED's capability-first handover doctrine for CLI, peer-agent, remote-device, connector, browser, and scheduled surfaces. Use before asking the user to perform a manual step.
---

# SAEED Handover Protocol — capability-first, manual-last

SAEED's default posture: **never offload to the human what an available, authorized automation surface can do.** A "you need to do X manually" instruction is a *last resort*, not a reflex. Before any agent emits one, it runs the check below — do it, drive it, or hand over a runnable packet — and only truly manual steps reach the user, with an explanation of why they could not be automated.

This canon is house standard, consulted automatically. It complements `orchestration-protocol` (how to run parallel work) and `continuous-improvement` (what to do next) with **how to close out the human-facing seam** without dumping chores on the operator.

## When this applies

Any moment an agent is about to tell the user to **do something themselves** — "create a Supabase project", "run this migration", "click Deploy in the dashboard", "add these secrets", "upload this file", "authorize the connector", "open the App Store Connect page", "install X", "send this email", "file the ticket". The instant you're about to write a manual to-do for the user, stop and run the ladder.

## The capability scan — what the current surfaces can actually do

Before declaring anything manual, inspect the channels that are actually present and authorized. Prefer a dedicated API or CLI over UI driving when both can complete the same action with the same authorization and evidence.

- **This session's APIs and CLI** — file tools, shell, `git`, repository CLIs, scripts, tests, and reachable services. Check installation, authentication, repository, and target before assigning work.
- **Peer agent or task surfaces** — Codex, Claude, Cowork, Grok, or another agent surface may help only after its current tools, account access, and write authority are observed. Produce a **handover packet** rather than assuming an account label proves capability.
- **Authorized remote shells and devices** — use SSH, device-management, or host-local tools only after reachability and target identity are verified. A saved alias, reachable peer, or earlier receipt is not proof that the required service is live now.
- **MCP connectors** — Gmail, Google Drive, Slack, Notion, Linear, Asana, Atlassian/Jira, ClickUp, Monday, Supabase, GitHub, and any other connected server. (Many need a one-time OAuth first — see auth gates.)
- **computer-use** — drive native desktop apps the user has granted (System Settings, Finder, native app UIs), take screenshots, click/type. Right for native apps with no dedicated MCP.
- **Browser automation** — drive web apps and provider dashboards when there is no API, CLI, or connector. Use one driver per browser profile or application at a time and explicitly release it before another controller takes over.
- **Scheduled tasks / background runs** — use a supported scheduler only when the operator requested recurring or deferred work. Do not convert an ordinary active-session request into an unattended watcher.
- **Document & research skills** — `docx`/`pptx`/`xlsx`/`pdf` generation, `WebFetch`/`WebSearch` for lookups — instead of asking the user to produce or find the artifact.

Look before asserting a limit: a claim that the available agents cannot do something must be grounded in channels you actually checked, not a guess. If a dedicated tool errors, debug or report it — do not silently fall through to "do it yourself".

## The decision ladder — do it → drive it → hand it over → (last) manual

1. **Do it now.** If a tool in *this* session can complete it, complete it. Don't narrate a manual step you could just perform.
2. **Drive it for you.** If it needs a connector, remote shell, computer-use, or the browser, drive that verified surface. Reuse authorization already present in the request/session; obtain approval only when the outward-facing or hard-to-reverse action is not already authorized (see safety).
3. **Hand it over.** If another verified agent or interactive surface has a capability this run lacks, perform a direct handover: send or emit a complete, self-contained packet addressed to that surface. Require acknowledgment of the task id, source or target, result branch when applicable, allowed actions, and return channel before treating it as active. If availability or access is unknown, record that limit rather than assigning work by assumption.
4. **Truly manual (last resort).** Only when **no** available automation surface can do it — a physical-world action, a credential/2FA/biometric only the human holds, a captcha, or an organization policy that mandates a human — hand back **exact** step-by-step instructions plus any command/prompt to paste, and **state plainly why it cannot be automated.**

Prefer the lowest-numbered tier that works. Escalate a tier only with a concrete reason ("this session has no Slack connector; the verified browser task does").

**Split mixed chains — never dump the whole flow on the user.** Real setup is usually a chain ("create the project → grab its ID → set a secret with it → deploy"), and only one link is truly human-only. Don't give up at the first manual link and hand back the entire chain, and don't barrel past a required human step. Instead: do every automatable link you can, hand back **only** the genuinely human-only link with exact steps, and sequence it — block on that one step, then continue automatically once the user reports it done (or once you can read the result). The handover packet's *Prerequisites* and *Hand back* fields are where you wire the two halves together.

## Auth gates are their own case

Many connectors need a one-time authorization the user must grant interactively. Treat "authorize connector X" as a genuine Tier-4 manual step when the current product cannot drive that consent — give the exact product-specific path you verified and explain what it unlocks. Never ask the user for auth codes, tokens, callback URLs, or session material.

## The handover packet (Tier 3) — make the target surface do the work

When you hand over to another agent or interactive surface, the packet is self-contained enough to send or paste and run:

- **Goal** — one line: what should end up true.
- **Where to run it** — the exact verified CLI, peer task, remote host, connector, or browser session — and why there.
- **Prompt to send** — the complete instruction addressed to the target agent/surface, with paths, IDs, repository, source commit, result branch, constraints, and forbidden actions.
- **Prerequisites** — connectors/access that must exist first (and how to grant them, per auth gates).
- **Definition of done** — what the result looks like so the user can confirm it worked.
- **Acknowledge and hand back** — the task, source or target, and result branch when applicable to acknowledge before work, then the link, commit, file path, evidence, and status to return.

The test: the user's only action is *paste and approve* — the target agent does the work.

## Safety carries over (never bypassed to "be helpful")

- **Require authorization for outward-facing or hard-to-reverse actions** — sending mail/messages, publishing, deleting/overwriting, deploying to production, spending money. Reuse explicit authorization within its stated scope; do not extend it to another target, branch, account, or action.
- **Never move money or execute trades/orders/transfers** on the user's behalf — always hand those back as Tier-4, even inside an otherwise automatable flow.
- **Link safety** — verify the full destination of any link from email/messages/unknown docs before following; open web URLs via the browser MCP, never by clicking in a native app.
- **Honesty** — if a step needed handover or is still pending, say so plainly; never report a manual step as done, and never half-do a driven action and imply completion.

## Pre-flight checklist — before any "you need to…" reaches the user

- [ ] Ran the capability scan — no verified channel (current API/CLI, peer agent, remote shell/device, MCP, computer-use, browser, or requested scheduler) can do it.
- [ ] Picked the lowest tier that works; any escalation has a concrete stated reason.
- [ ] Tier 1/2 actions were actually performed (not described), after verifying required authorization within its stated scope and honoring any platform-required action-time confirmation.
- [ ] Tier 3 handovers ship a complete, paste-and-run packet — the user pastes, the target agent acts.
- [ ] Tier 4 manual asks are genuinely unautomatable, say **why**, and include exact steps + any prompt/command to paste.
- [ ] Auth-gate asks name the exact grant path and what it unlocks.
- [ ] Safety respected; status reported honestly (done / driven / handed over / pending).

A deliverable that hands the user a chore an available automation surface could have done is **not done**. Automate it, drive it, or package it; leave only the truly manual, and explain it.

## Attribution

Native SAEED operating doctrine (not distilled from an external skill), added at the operator's direction: evaluate every manual ask against the verified surfaces available now, and hand over directly wherever possible.
