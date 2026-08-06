---
name: app-hardening
description: SAEED's absorbed product-hardening canon — the seventeen-point pre-ship gate: rate limiting, server-only secrets, RLS, .env hygiene, input validation, deny-by-default access, route auth, generic errors, locked admin, attack logging, IDOR, real logout, safe uploads, verified webhooks, centralized authz, data-model ownership — plus the change-level security review. Defends the product; `skills/agentic-security/SKILL.md` defends the team.
---

# SAEED App Hardening — the absorbed pre-ship gate

Absorbed from the operator's own securitymaxxing checklist — ten points as
first absorbed, extended to seventeen by the operator's 2026-08-06 audit
checklist (Security section, Michael Ly + Casco) — the
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

## The seventeen-point pre-ship gate (numbered as the operator wrote it)

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
11. **IDOR protection — object-level authorization on every data request.**
    Rule 7 checks *who the caller is*; this rule checks *whether that caller
    may touch this specific record*. Every read or write that takes an
    identifier — URL param, body field, filename — verifies server-side that
    the authenticated caller holds permission on that object, never inferring
    permission from the ID being known. Unguessability is not authorization:
    a UUID key is as vulnerable to IDOR as a sequential integer once it
    leaks. Refuse to ship a handler that fetches by ID with no ownership or
    permission predicate beside the fetch.
12. **Proper logout — invalidate server-side, clear client-side.** Logout
    revokes the session on the server (session row deleted, token revoked or
    denylisted) **and** clears cookies, local storage, and session storage on
    the client. A logout that only clears the client leaves a live
    credential replayable from any stolen copy. The proof is a post-logout
    request with the old token being rejected — refuse a logout that cannot
    demonstrate it.
13. **File upload safety.** Every upload validates type against an allowlist
    by content inspection (never the extension or the client's Content-Type
    alone), enforces a size cap, and lands in non-executable storage — an
    object-storage bucket, never the webroot — served back with a safe
    content type or download disposition. Bucket policy and storage-RLS
    depth on Supabase is `skills/supabase-craft/SKILL.md`'s; this rule is
    the refusal when an upload path skips any of the three checks.
14. **Webhook signature verification.** Every webhook consumer verifies the
    provider's signature (Stripe, or any signing provider) against the raw
    request body before trusting the payload — an unverified payment webhook
    means anyone who finds the URL can mint fake payment events. Pair it
    with idempotency on the event ID so a replayed event cannot double-apply.
    Refuse a webhook route shipping without verification and a test proving
    a bad signature is rejected.
15. **Deny-by-default access control, everywhere.** Rule 6 states the
    posture for tables; the same posture binds every other resource — routes,
    storage buckets, RPC functions, feature flags, API scopes. Nothing is
    reachable unless a named rule explicitly allows it; "public for now,
    lock it down later" is a finding at any layer, not only the database.
16. **Centralized access checks.** Authorization runs through one reusable,
    tested layer — a middleware, a policy module, the RLS policies of rule 3
    — that every endpoint passes through, never bespoke permission logic
    hand-rolled per endpoint. N copies of a check drift independently, and
    the one forgotten copy is the breach. A new endpoint re-implementing a
    check the central layer already owns is a finding even when its logic is
    currently correct.
17. **Record ownership enforced at the data-model level.** Every user- or
    tenant-scoped record carries its owner in the schema itself — an
    `owner_id`/`tenant_id` column with a real foreign key — so the database
    knows who owns what without consulting application code. Rules 3 (RLS)
    and 16 (the central check) bind to that column; ownership living only in
    application bookkeeping, or nowhere, fails this gate even when RLS is
    technically enabled.

## The change-level security review

The seventeen-point gate is the pre-ship snapshot; a pending diff gets a security
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
- [ ] (11) Every handler taking an object identifier carries an ownership/permission predicate beside the fetch — no IDOR.
- [ ] (12) Logout invalidates the session server-side **and** clears cookies/local/session storage; the old token demonstrably stops working.
- [ ] (13) Every upload path validates type by content, caps size, and stores in a non-executable location.
- [ ] (14) Every webhook verifies the provider's signature on the raw body, with a bad-signature rejection test and event-ID idempotency.
- [ ] (15) Every resource layer — routes, buckets, RPCs, flags, scopes — is deny-by-default, not only tables.
- [ ] (16) Authorization runs through one central layer; no endpoint hand-rolls its own copy of an existing check.
- [ ] (17) Every user-/tenant-scoped table carries its owner as a real column + FK the policies bind to.
- [ ] N/A claims name the reason (no network/UI surface) rather than silently skipping.

A shippable change is **not done** until this checklist passes and
`appsec-engineer` returns a verdict — escalated from Verification Protocol
gate 5, consumed by `the-boss`'s Definition of Done.

## Wiring

- **Owner:** `appsec-engineer` — stewards this canon and is the named gate:
  runs the seventeen-point verdict at pre-ship and the diff-level review under
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
securitymaxxing pre-ship checklist, extended to seventeen points by the
Security section (credited to Michael Ly + Casco) of the operator's
2026-08-06 audit checklist — items 11–17 above, in the order the operator
wrote them (source preserved in `.saeed/tasks/cycle-10/sources/`). When the
`anthropic-skills:securitymaxxing` session skill is installed, prefer
invoking it for full depth; this file guarantees the standard when it is not.
