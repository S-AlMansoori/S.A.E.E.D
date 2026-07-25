---
name: app-hardening
description: SAEED's absorbed product-hardening canon — the ten-point pre-ship gate (rate limiting, server-side secrets, RLS everywhere, .env hygiene, input validation, explicit permissions, auth on protected routes, generic errors, locked-down admin surfaces, attack-visible logging) plus the change-level security review. Defends the product SAEED ships; `skills/agentic-security/SKILL.md` defends the team.
---

# SAEED App Hardening — the absorbed pre-ship gate

Absorbed from the operator's own ten-point securitymaxxing checklist: the
product-hardening habits every SAEED-built app must show before it ships,
distilled into a match-and-refuse gate instead of advisory prose. This canon
defends the **product**; `skills/agentic-security/SKILL.md` defends the
**team** — the autonomous fleet building it. Same defensive posture, two
different surfaces. Where a rule's ownership already lives with another
canon or agent, this file points there once and never restates it.

## Scope — when this applies

Binds **every SAEED agent that ships or reviews a network-reachable surface**:
an API route, a server action, a Supabase table, an admin panel, a webhook,
a background job with an HTTP trigger. It is the pre-ship gate — checked
before Phase 3 verification signs off, and re-checked on any diff that
touches auth, input handling, secrets, or an admin/debug surface.

**Does NOT apply** — mark N/A with the reason, don't skip silently — to
work with no network or UI surface at all: a pure CLI script never exposed
as a service, a one-off data migration run by hand, a local-only dev tool
never deployed. The moment such a thing gains an HTTP listener or a
deployment target, the gate applies.

## Invoke the deep skills (when the Skill tool is available to you)

| Task in front of you | Invoke |
|---|---|
| Full-depth pre-ship security pass over the whole checklist | `anthropic-skills:securitymaxxing` |
| Change-level security review of a pending diff | `/security-review` (session command, when installed) |

If none are installed, the canon below still fully applies. Never let a
missing plugin lower the bar.

## The ten-point pre-ship gate (numbered as the operator wrote it)

Match-and-refuse: each rule is a shape to recognize and a refusal to give
when it's missing, not a suggestion to weigh.

1. **API rate limiting.** Every public or authenticated endpoint that does
   real work (writes, sends, searches, calls an LLM/third-party API) carries
   a rate limit — per-IP at minimum, per-user/per-key where identity exists.
   An endpoint with no limit is not "fast", it is an open amplifier for
   abuse and cost. Refuse to ship a new route without naming its limit.
2. **Secrets stay server-side only.** API keys, service-role keys, and
   webhook secrets never reach client bundles, client-side env vars
   (`NEXT_PUBLIC_*`/`EXPO_PUBLIC_*` and equivalents), or a browser network
   tab. Every secret-using call runs in a server component, route handler,
   Edge Function, or backend service — never a client component. What
   happens *after* a secret leaks (rotate, sweep, log) is
   `skills/agentic-security/SKILL.md`'s secrets response protocol, not this
   file's job.
3. **Row-level security on every table.** Every table holding
   user-scoped or tenant-scoped data has RLS enabled and a policy proving
   it, not a bare `ENABLE ROW LEVEL SECURITY` with no `CREATE POLICY`
   beside it. Design, migration, and troubleshooting doctrine for RLS lives
   in `skills/supabase-craft/SKILL.md` — cross-referenced, not repeated.
4. **`.env` never enters the repo.** Every environment file with real
   values is listed in `.gitignore` before the first commit that could
   contain one; only `.env.example` (placeholder values) is tracked. A
   history that already contains a real `.env` is a leak — hand off to the
   agentic-security secrets response protocol, don't just add the
   `.gitignore` line after the fact and call it fixed.
5. **Input validation and sanitization at every boundary.** Every
   externally-reachable input — request body, query param, header, form
   field, file upload, webhook payload — is validated against a schema and
   sanitized before use, server-side, regardless of what client-side
   validation already ran (client checks are UX, never the security
   control). Injection classes, encoding rules, and the full OWASP mapping
   are `appsec-engineer`'s doctrine to apply in review; this rule is the
   pre-ship checkbox that its finding traces back to.
6. **No default-public tables.** Every new table starts with explicit,
   named permissions — deny by default, grant by rule — never the
   convenience of "public for now, lock it down later." Ownership and
   policy authoring is `skills/supabase-craft/SKILL.md`'s; this rule is
   the refusal at ship time when a table has none.
7. **Auth required on every protected route.** Any route serving
   non-public data or performing a state-changing action checks the
   caller's identity and authorization on the server, on every request —
   never trusting a hidden URL, a client-side redirect, or a check that
   ran once on a different route. A route with a comment saying "assumes
   the user is logged in" and no server-side check is a finding, not a
   pass.
8. **Generic user-facing errors, no stack traces.** Client-visible error
   responses carry a generic message and (where useful) a correlation ID —
   never a stack trace, a raw exception message, an internal file path, a
   SQL error, or a library version string. Detail goes to the server log,
   not the response body. The exploitable-detail taxonomy and the fix
   pattern for a given leak are `appsec-engineer`'s to specify; this rule
   is the pre-ship refusal when a raw error reaches the wire.
9. **Admin and debug endpoints locked or disabled in production.** Any
   `/admin`, `/debug`, `/internal`, health-check-with-detail, or
   feature-flag-toggle surface is either absent from the production build,
   gated behind real authorization (not a query-string flag or a
   "security through obscurity" path), or network-restricted at the
   infrastructure layer. Naming and shipping this surface correctly is
   this canon's own new doctrine; provisioning the network restriction
   (VPC, allow-list, private endpoint) is `cloud-infra-engineer`'s to
   execute.
10. **Logging and monitoring that can show an attack.** Auth failures,
    rate-limit trips, validation rejections, and admin-surface access are
    logged with enough context (timestamp, route, caller identity or IP,
    outcome) to reconstruct an attack after the fact — never logged with
    secrets or PII in the payload. Instrumentation, alerting, and dashboard
    ownership is `sre-observability-engineer`'s; this rule is the pre-ship
    check that the signal exists at all before ship, not added after the
    first incident.

## The change-level security review

The ten-point gate is the pre-ship snapshot; a pending diff gets a security
*review* at the depth the change deserves. `/saeed:verify` carries a
security-depth mode — invoked explicitly or auto-escalated when the diff
touches auth, input handling, secrets, the network boundary, new
dependencies, or an admin/debug surface — that runs `appsec-engineer`
over the diff and its blast radius, ending in an explicit pass/block
verdict. The mode itself is documented once, in `commands/verify.md`; this
paragraph is the pointer, not a second copy.

## Pre-ship checklist

- [ ] (1) Every new endpoint doing real work names its rate limit.
- [ ] (2) No secret reachable from a client bundle or `NEXT_PUBLIC_*`/`EXPO_PUBLIC_*` var.
- [ ] (3) Every user- or tenant-scoped table has RLS enabled **and** a policy.
- [ ] (4) No `.env` with real values tracked; `.gitignore` covers it before first commit.
- [ ] (5) Every external input is validated and sanitized server-side.
- [ ] (6) Every new table starts deny-by-default, not public-by-default.
- [ ] (7) Every protected route checks identity and authorization server-side, every request.
- [ ] (8) No stack trace, raw exception, internal path, or SQL error reaches a client response.
- [ ] (9) No admin/debug surface reachable in production without real authorization.
- [ ] (10) Auth failures, rate-limit trips, and admin access are logged with reconstructable context, secret- and PII-free.
- [ ] N/A claims name the reason (no network/UI surface) rather than silently skipping.

A shippable change is **not done** until this checklist passes and
`appsec-engineer` returns a verdict — escalated from Verification Protocol
gate 5, consumed by `the-boss`'s Definition of Done.

## Wiring

- **Owner:** `appsec-engineer` — stewards this canon and is the named gate:
  runs the ten-point verdict at pre-ship and the diff-level review under
  `/saeed:verify`'s security depth.
- **Applying class:** `security-architect`, `devsecops-engineer`,
  `backend-engineer`, `frontend-engineer`, `api-designer`,
  `database-architect`, `edge-serverless-engineer`,
  `sre-observability-engineer` (item 10 instrumentation),
  `cloud-infra-engineer` (item 9 network lockdown).
- **Gate:** `appsec-engineer`'s pre-ship verdict, escalated from
  Verification Protocol gate 5 (`skills/verification-protocol/SKILL.md`);
  a red verdict blocks ship until fixed or an explicit N/A with reason.
- **Deliberate exclusions:** work with no network or UI surface (see
  Scope); the agent-layer threat model (prompt injection, the unattended
  trifecta, secrets *response*) — that is
  `skills/agentic-security/SKILL.md`'s, cross-referenced above, never
  restated here; RLS/table-permission authoring depth — that is
  `skills/supabase-craft/SKILL.md`'s.

## Attribution

This canon distills, with gratitude, the operator's own ten-point
securitymaxxing pre-ship checklist. When the `anthropic-skills:securitymaxxing`
session skill is installed, prefer invoking it for full depth; this file
guarantees the standard when it is not.
