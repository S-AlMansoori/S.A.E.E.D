---
name: supabase-craft
description: SAEED's absorbed Supabase and Postgres canon — schema and migrations, Auth/JWT/RLS and @supabase/ssr sessions, Edge Functions, Realtime, Storage, Vectors, Cron, Queues, client patterns with service-role isolation, CLI/MCP, security advisors, extensions, and query/schema/config performance. Applied automatically by every data-touching SAEED agent on any Supabase or Postgres work.
---

# SAEED Supabase Craft — the absorbed canon

SAEED has absorbed Supabase product mastery and Postgres performance doctrine as house standard: schemas, auth flows, Edge Functions, and queries are **right the first time**, not debugged after delivery. This file is the floor every data-touching agent clears automatically; the named session skills are the depth.

## Scope — when this applies, and the adapt-to-repo rule

Two doctrines travel at different radii, and every agent applying this canon states which radius it is in:

- **Postgres doctrine** (schema shape, migrations, indexing, query/schema/config performance) applies to **any Postgres**, Supabase-hosted or self-managed — the rules below hold with no Supabase in the stack at all.
- **Supabase product doctrine** (Auth/JWT/RLS-as-policy, Edge Functions, Realtime, Storage, Vectors, Cron, Queues, the CLI, the MCP server, security advisors) applies **only where Supabase is present**.

**Does not apply / N/A:** a repo with no relational database (a static site, a mobile app with only on-device storage) records N/A with the reason. A non-Postgres relational store takes the normalization, constraint, and access-control *judgment* here by analogy but is never held to Postgres-specific syntax or Supabase product surfaces.

## Invoke the deep skills (when the Skill tool is available to you)

| Task in front of you | Invoke |
|---|---|
| Any Supabase product task — Auth, Edge Functions, Realtime, Storage, Vectors, Cron, Queues, CLI, MCP server, security advisors | `supabase` |
| Postgres query, schema, or config performance review or tuning | `supabase-postgres-best-practices` |

Never let a missing plugin lower the bar.

## Database — schema, migrations, expand/contract

- Model for integrity first: correct types, `NOT NULL` by default, foreign keys with an explicit `ON DELETE` policy, `UNIQUE` and `CHECK` constraints doing the work application code would otherwise have to re-verify. Normalize until it hurts; denormalize only with a measured reason recorded next to the table.
- Every table that holds user or tenant data gets a stable primary key (`uuid` via `gen_random_uuid()` or a bigint identity) and, where multi-tenant, an explicit tenant/owner column the RLS policies key on — added at creation, never bolted on later as a migration surprise.
- **Migrations are expand/contract, reversible, never a destructive big-bang:** add the new column nullable → backfill in batches → add the `NOT NULL`/constraint in a follow-up migration → only then drop the old column or table, in a migration that ships after the reads have moved off it. Every forward migration ships with a rollback path (a paired `down` migration, or a documented manual undo when Supabase's migration tooling doesn't generate one); verify both directions against a copy of the schema before it touches production.
- Never disable RLS "to make it work," and never ship a migration that drops or truncates data without a verified backup in hand.

## Auth — JWT lifecycle, `@supabase/ssr` sessions, RLS troubleshooting

- **JWT lifecycle:** a short-lived access token plus a longer-lived, rotating refresh token; `auth.uid()` and `auth.jwt()` are the identity primitives every RLS policy and trigger reads. Prefer `getClaims()`/session-verified reads over trusting a client-supplied user id anywhere server-side.
- **`@supabase/ssr` — browser vs server client, the one scoped line for `frontend-engineer`** (the single client-boundary mistake severe enough that a UI-only agent must carry it even though the rest of this canon is `database-architect`'s): Client Components use the **browser client** (`createBrowserClient`), which reads/writes the session through cookies the browser already owns. Server Components, Route Handlers, Server Actions, and middleware use the **server client** (`createServerClient`), wired to the framework's cookie `get`/`set`/`remove` (Next.js `cookies()`). Never construct one where the other belongs — a browser client used server-side loses the request's cookie jar; a server client's service-role variant used client-side ships a master key to every visitor. **The service-role key never ships in a client bundle, full stop** — it belongs in server-only environment variables, never `NEXT_PUBLIC_*`, and its use is confined to trusted server code that has already re-verified the caller. Session refresh happens in middleware so Server Components never race a stale token.
- **RLS troubleshooting:** a policy per operation (`select`/`insert`/`update`/`delete`, never one policy trying to cover all four), scoped with `auth.uid() = owner_column` or a tenant-membership subquery, `USING` for what a row can be read/touched under and `WITH CHECK` for what a row can be written as. The service role bypasses RLS entirely — that is precisely why it never leaves the server. A query that returns fewer rows than expected is almost always a policy the query doesn't satisfy, not a bug in the query; add a role-scoped test query before assuming the SQL is wrong.

## Edge Functions

Deno-runtime, deployed per-function, cold-start-sensitive: keep the import graph small, prefer the Deno standard library and `npm:`-specifier imports Supabase supports over heavy bundlers. Verify the caller (JWT verification is on by default; disable only for genuinely public webhooks, and verify the webhook's own signature instead). Secrets come from `supabase secrets set`, read via `Deno.env.get`, never hard-coded. A function that needs elevated access uses the service-role key *inside* the function's server-side runtime only — the same never-in-the-client rule as above, restated here because Edge Functions are the other place a service-role key is tempting to leak into a response.

## Realtime

Subscribe to the narrowest channel and filter server-side (`filter:` on the subscription), never fetch-everything-and-filter-in-the-client. Realtime respects RLS on Postgres Changes — a client only receives change events for rows its own policies would let it select, so a broadcast that "isn't arriving" is frequently a policy gap, not a subscription bug. Broadcast and Presence channels are unauthenticated by default unless Realtime Authorization is configured; treat an unauthenticated channel as a public surface and never put sensitive payloads on it.

## Storage

Buckets are either public (readable by any unsigned URL) or private (RLS-gated via `storage.objects` policies, same policy-per-operation discipline as any other table). Default to private; make a bucket public only for content that is genuinely meant to be world-readable. Validate file type and size before upload, on both the client (fast feedback) and a server-side check or a Storage policy (the enforcement that actually holds). Signed URLs carry a deliberately short expiry for anything sensitive.

## Vectors

`pgvector` columns are ordinary Postgres columns: index them (`ivfflat` or `hnsw`, chosen for the recall/latency tradeoff the workload needs) once row counts make a sequential scan too slow, and keep the embedding dimension and distance operator (`<->`, `<#>`, `<=>`) consistent across every query touching the column. Deep retrieval-quality and embedding-pipeline design is `vector-search-engineer`'s ownership (cross-reference, not restated here) — this canon covers the column existing correctly in the schema.

## Cron & Queues

`pg_cron` schedules SQL or a `net.http_post` call on a cron expression stored in the database itself, auditable by `SELECT * FROM cron.job`; prefer it over an external scheduler for anything that only needs to run SQL. `pgmq` (or an Edge Function polling loop) gives at-least-once queue semantics — design consumers to be idempotent (a message may be delivered twice), and set a visibility timeout longer than the worst-case processing time so a slow job doesn't get double-picked-up.

## `supabase-js` client patterns

One client instance per runtime context, not one per request. Browser code gets exactly one browser client (anon key, RLS-bound); server code gets a server client per request (respects the caller's session) plus, only where genuinely needed, a separate service-role client instantiated in server-only code and never returned to a caller. Chain `.select()` to name the exact columns needed, never `select('*')` on a table with columns a client shouldn't see even under RLS — RLS gates rows, not columns.

## CLI + MCP

`supabase migration new` / `supabase db push` / `supabase db diff` drive schema change through the same expand/contract discipline as any other migration path — the CLI is a delivery mechanism, not an exemption from it. The Supabase MCP server gives an agent direct project access (tables, migrations, logs, advisors); treat it like any other MCP server under `skills/agentic-security/SKILL.md` — read-only exploration is safe by default, and a write action against a project the operator didn't explicitly name is a scope violation, not an initiative.

## Advisors & audits

Run the Supabase security and performance advisors (or their SQL equivalents against `pg_stat_*` and the RLS catalog) before calling a schema done: a table with RLS enabled but zero policies is a de facto deny-all, and a table with RLS disabled entirely is a finding, not a style choice. A flagged table with no RLS, or an RLS-less table found in review, is routed to `code-reviewer` as a blocking finding — the gate lives there, not in this canon.

## Extensions

Enable only the extensions a schema actually uses (`pgvector`, `pg_cron`, `pgmq`, `pg_graphql`, `postgis`, …) — an enabled-but-unused extension is attack surface and a migration-ordering trap for anyone cloning the schema fresh. Extension version pinning follows the same reversibility discipline as any migration: know how to disable one before enabling it.

## Postgres performance — query, schema, config (the read-side seam)

- **Schema-level:** index every foreign key that is actually queried (Postgres does not do this automatically); prefer a composite index ordered by selectivity over several single-column indexes for a multi-predicate query; avoid over-indexing a write-heavy table — every index is a write-path cost, not a free lunch.
- **Query-level:** read `EXPLAIN (ANALYZE, BUFFERS)` before guessing; a sequential scan is not automatically wrong on a small or rarely-queried table, and an index the planner refuses to use is usually a stale statistics or type-mismatch problem, not a broken index.
- **Config-level:** connection pooling (Supavisor/PgBouncer in transaction mode for serverless/edge callers) over one raw connection per request; `work_mem`, `shared_buffers`, and `statement_timeout` are workload-tuned, never left at defaults for a production instance under real load.
- **The read-side seam, explicit:** this canon covers a schema and query shaped correctly from the start. Deep query diagnosis under load — plan-shape investigation, index-strategy iteration on a live slow query, connection-pool sizing under contention — is `query-optimization-engineer`'s ownership. Cross-reference it; do not re-derive its method here.

## Wiring

- **Owner:** `database-architect` — stewards this canon, the schema/migration/RLS doctrine above, and the Postgres-performance half's schema/index rules.
- **Applying class:** `backend-engineer`, `query-optimization-engineer` (query-level performance, the read-side seam above), `data-engineer`, `realtime-engineer`, `edge-serverless-engineer`, `api-designer`, `devops-platform-engineer` (migration pipelines), and `frontend-engineer` — scoped to the `@supabase/ssr` browser-vs-server client line and the never-service-role-in-the-client rule, because a service-role key leaked into a client bundle is a full-project compromise a UI agent must be able to catch on sight; the data-side doctrine stays with `database-architect`.
- **Gate:** `code-reviewer` flags RLS-less tables, a service-role key anywhere in client-reachable code, and unsafe (non-expand/contract) migrations in any diff it reviews. Client-bundle secret exposure additionally cross-references `skills/app-hardening/SKILL.md` items (2)/(3)/(6).
- **Deliberate exclusions:** `security-architect` and `appsec-engineer` are **not** in the applying class — RLS-authoring judgment lives here, but threat modeling and the product-wide hardening gate are `skills/app-hardening/SKILL.md`'s job, and folding a schema canon into that ownership would blur the boundary rather than sharpen it. `vector-search-engineer` is cross-referenced above, not applying, for the same reason: embedding-pipeline and retrieval-quality design is its own canon's territory; this one stops at the `pgvector` column existing correctly in the schema. `cloud-infra-engineer` and `sre-observability-engineer` also plausibly touch "the database" but are excluded — provisioning-as-code and SLOs/alerting are their canons, not schema or RLS judgment.

## Attribution

This canon distills Supabase's own product documentation and Postgres performance best practices into house doctrine. When the `supabase` and `supabase-postgres-best-practices` skills are installed, prefer invoking them for their full depth; this file guarantees the standard when they are not.
