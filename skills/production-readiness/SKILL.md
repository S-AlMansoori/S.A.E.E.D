---
name: production-readiness
description: SAEED's production-readiness canon — the ops pre-ship gate: backups proven by an actual restore (RPO/RTO), a product disaster-recovery runbook, dev/staging/prod tiers with per-env secrets, load-verified performance targets, caching with TTL + invalidation, encryption at rest with named key custody, and a named compliance surface (GDPR, UAE PDPL, SOC 2). Defends the product from entropy as app-hardening defends it from attack.
---

# SAEED Production Readiness — the ops pre-ship gate

Absorbed from the operator's 2026-08-06 capability mandate ("I want SAEED to
do all this"), landed as the ops twin of `skills/app-hardening/SKILL.md`:
that canon defends the product from **attackers**; this one defends it from
**entropy** — data loss, outages, load, and the compliance question nobody
asked until a customer did. Every rule below traces to a hole the cycle-11
coverage audit proved with a zero-hit grep, not to a best-practices article:
before this file, RPO, RTO, PITR, restore drill, staging, load test, k6,
GDPR, and SOC 2 appeared **nowhere** in the fleet's doctrine. Match-and-refuse,
same posture as the security gate: each rule is a shape to recognize and a
refusal to give when it's missing.

## Scope — when this applies

Binds **every SAEED agent that ships or reviews a deliverable that runs as a
service with persistent state or a stated availability expectation**: an API
with a database behind it, an app with user uploads, a scheduled job whose
output someone depends on. Checked before Phase 3 verification signs off,
beside (never instead of) the `skills/app-hardening/SKILL.md` gate.

**Does NOT apply** — mark N/A with the reason, don't skip silently — to a
deliverable with no persistent state and no availability promise: a static
site whose only state is its hosting provider's, a pure CLI tool, a library,
a prototype the intake explicitly labelled non-production. The moment such a
thing gains a database, user data, or a paying user, the gate applies — the
same activation shape as the app-hardening HTTP-listener clause.

## Invoke the deep skills (when the Skill tool is available to you)

| Task in front of you | Invoke |
|---|---|
| Pre-deploy verification sweep before a release | `engineering:deploy-checklist` |
| Supabase backup/PITR/branching mechanics in depth | `supabase` (with `skills/supabase-craft/SKILL.md` as the house floor) |

If none are installed, the canon below still fully applies. Never let a
missing plugin lower the bar.

## The seven rules (match-and-refuse)

1. **Backups that have actually restored.** Every stateful store — the
   database, object storage, the vector store, anything a user would miss —
   has automated backups on a schedule, a named **RPO** (how much data loss
   is acceptable) and **RTO** (how long recovery may take), and PITR where
   the platform offers it. The teeth: a backup that has never been restored
   is a hope, not a backup — before first ship, and on a recurring cadence
   after, a restore is **performed** into a scratch target and the evidence
   (timestamp, target, row/object counts) recorded. Refuse to ship a
   stateful service whose backup story is a provider checkbox nobody has
   exercised. Backup *mechanics* per store: `skills/supabase-craft/SKILL.md`
   for Postgres/Supabase; provisioning the schedule as IaC is
   `cloud-infra-engineer`'s.
2. **A disaster-recovery runbook for the product.** The named failure
   scenarios — data loss/corruption, provider or region outage, a destroyed
   environment — each carry written recovery steps, an owner, and an
   estimated recovery time that fits the stated RTO. This is the *product's*
   runbook; the team's own repo-state recovery is
   `skills/self-governance/SKILL.md`'s and is not restated here.
3. **Three environment tiers by default.** Dev, **staging**, prod — staging
   tracks prod's shape (same migrations, same infra class, realistic data
   volumes), every tier carries its **own secret set**, and a prod
   credential never appears in a lower tier. Promotion is configuration,
   never a code edit. A two-tier setup is a recorded ruling for a genuinely
   tiny deliverable (observable predicate: no schema migrations and no
   third-party side effects to rehearse), never a silent default.
4. **Load-verified non-functional targets.** Any service with stated
   latency/throughput targets (set at intake) proves them under **generated
   load** — k6 or equivalent — at the expected concurrency, asserting on
   percentiles (p95/p99), never one lucky run. The capacity plan names the
   scaling path: vertical first, horizontal when measurement demands it —
   which keeps faith with the house rule against speculative scaling
   (`agents/principal-architect.md`): you don't build for the hyperscaler,
   but you do *prove* the load you claimed. A target with no load test
   behind it is a wish; a user-facing service with no target gets one before
   it ships.
5. **Deliberate caching with an invalidation story.** An application-level
   cache (Redis, KV-as-cache, in-process) is earned, not sprinkled: only a
   *measured* hot path gets one — rule (3) of
   `skills/performance-discipline/SKILL.md` names the slowest dependency
   first, and a slow query gets fixed (`agents/query-optimization-engineer.md`)
   before it gets cached around. Every cache entry ships with a TTL, a named
   invalidation trigger for writes, and the never-cache list: authz-scoped
   data across identities, tokens, anything RLS was protecting. An unbounded
   or unowned cache is a correctness bug wearing a performance hat. The same
   contract binds edge caches (`agents/edge-serverless-engineer.md`).
6. **Encryption at rest with named key custody.** In transit is
   `agents/network-engineer.md`'s TLS/mTLS doctrine — pointer, not a
   restatement. At rest: platform-level encryption is **verified, not
   assumed**, on every store — database, buckets, and the *backups of both*
   (an encrypted database with plaintext dumps is rule 1 undoing rule 6) —
   with field-level encryption where high-sensitivity PII warrants it. Keys
   live in a managed store with a rotation schedule and a named custodian;
   what happens after a key or secret *leaks* is
   `skills/agentic-security/SKILL.md`'s response protocol.
7. **A named compliance surface.** Before ship, the deliverable names which
   regimes apply — **GDPR** (EU users), **UAE PDPL** (the house's home
   region), **SOC 2** (B2B buyers will ask), **HIPAA**/**PCI-DSS** (health
   or payment data) — or records "none applies" with the reason. The
   mapping, and the control checklist each named regime implies, is
   `agents/compliance-privacy-engineer.md`'s to produce in its
   advisory-not-legal-advice register. An app holding EU-resident PII with
   no GDPR word anywhere in its spec is a finding, not an oversight.

## Pre-ship checklist

- [ ] (1) Every stateful store has scheduled backups, a named RPO/RTO, and recorded evidence of an actual restore.
- [ ] (2) A product DR runbook exists: scenarios, steps, owners, recovery-time estimates within the stated RTO.
- [ ] (3) Dev/staging/prod exist with per-tier secret sets; no prod credential in a lower tier; two-tier only by recorded ruling.
- [ ] (4) Stated latency/throughput targets are proven under generated load at expected concurrency (percentile assertions).
- [ ] (5) Every application/edge cache entry has a TTL + invalidation trigger; nothing authz-scoped is cached across identities.
- [ ] (6) Encryption at rest verified on every store *including backups*; keys in a managed store with rotation + named custody.
- [ ] (7) Applicable compliance regimes are named (or "none applies" with reason) with their control checklist.
- [ ] N/A claims name the reason (no persistent state and no availability promise) rather than silently skipping.

A shippable service is **not done** until this checklist passes and
`sre-observability-engineer` returns a verdict — consumed by `the-boss`'s
Definition of Done beside the `skills/app-hardening/SKILL.md` verdict.

## Wiring

- **Owner:** `sre-observability-engineer` — stewards this canon and is the
  named gate: runs the seven-point verdict at pre-ship; a red verdict blocks
  ship until fixed or an explicit N/A with reason.
- **Applying class:** `database-architect` (rule 1 data-layer mechanics),
  `cloud-infra-engineer` (rules 1 and 6 provisioning as IaC),
  `devops-platform-engineer` (rule 3 tiers and secret scoping),
  `qa-automation-engineer` + `test-architect` (rule 4 load tests and their
  strategy tier), `backend-engineer` + `edge-serverless-engineer` (rule 5),
  `security-architect` (rule 6 requirements), `compliance-privacy-engineer`
  (rule 7, advisory register).
- **Gate:** `sre-observability-engineer`'s pre-ship verdict, alongside
  Verification Protocol gates (`skills/verification-protocol/SKILL.md`) and
  the `skills/app-hardening/SKILL.md` security verdict — two gates, one
  Definition of Done.
- **Deliberate exclusions:** the team's own repo/disaster recovery
  (`skills/self-governance/SKILL.md`); wire/data performance rules
  (`skills/performance-discipline/SKILL.md` — rule 5 here *composes with*
  its rule 3, never replaces it); deep query optimization
  (`agents/query-optimization-engineer.md`); TLS mechanics
  (`agents/network-engineer.md`); Supabase backup/RLS mechanics
  (`skills/supabase-craft/SKILL.md`); the security pre-ship gate itself
  (`skills/app-hardening/SKILL.md`) — beside, never merged, so the ops
  verdict and the security verdict stay separable at the same DoD.

## Attribution

This canon distills, with gratitude, the operator's 2026-08-06 capability
mandate — Security & Compliance, Testing & Quality, System Architecture &
Infrastructure, DevOps & Deployment ("feel free to add stuff" taken at its
word) — grounded rule-for-rule in the cycle-11 coverage audit's zero-hit
evidence rather than general knowledge (source preserved in
`.saeed/tasks/cycle-11/sources/`). The restore-or-it-isn't-a-backup teeth,
the staging-tier default, and the named-regime rule are the audit's three
largest proven holes, written down where they can refuse.
