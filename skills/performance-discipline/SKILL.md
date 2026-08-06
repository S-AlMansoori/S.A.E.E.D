---
name: performance-discipline
description: SAEED's absorbed wire-and-data performance canon — never ship uncompressed responses, never write rows one at a time when a batch exists, name the slowest dependency before optimizing, update UI optimistically with reconciliation, serve static frontends statically — plus the standing inherited-backend audit run on every hire: over-fetched queries, N+1 sweeps, unreleased database connections, orphaned storage blobs, and background jobs holding pool connections. Match-and-refuse rules with default remedies for every service and frontend SAEED builds or reviews.
---

# SAEED Performance Discipline — fast by construction

SAEED has absorbed Hayden Smith's five slow-app reasons as house doctrine. Their combined lesson: most production slowness is not a hard algorithmic problem, it is one of five construction mistakes repeated project after project. This canon makes each mistake a match-and-refuse rule with a default remedy, applied **automatically, without being asked**, the same way `skills/design-excellence/SKILL.md` treats its absolute bans.

## Scope (and what stays out)

**Owns:** wire, data, and hosting performance — response payload size, database write patterns, network round-trip audits, optimistic-UI update strategy, and how a static frontend is served. This is the axis that makes an app *feel* fast before a single pixel paints.

**Does not own — cross-referenced, never restated:**

- **Render and animation performance** (GPU-safe motion, scroll-thrash, `backdrop-blur` placement, Core Web Vitals from paint/layout cost) is `skills/design-excellence/SKILL.md`'s "Performance guardrails" section. That canon owns the pixel; this one owns the wire.
- **Deep query work** — EXPLAIN plans, indexing, query rewrites, connection-pool tuning — belongs to `agents/query-optimization-engineer.md`. This canon's rule (3) says *audit and name the slowest dependency*; if that dependency is a query, route it there rather than re-deriving query doctrine here.
- **N+1 spotting inside code review** is a flag-and-route in `agents/code-reviewer.md`, not a second home for the rule — see the mechanical gate below.

**Does not apply:** a deliverable with no network boundary, no persistence layer, and no hosted frontend — a pure local CLI utility or an offline batch script with zero I/O to another system — is N/A. Record the reason; don't force a rule where there is no wire to measure.

## Invoke the deep skill (when the Skill tool is available to you)

| Task in front of you | Invoke |
|---|---|
| Full-depth review beyond the five rules below — N+1 queries, injection risks, missing edge cases, error-handling gaps | `/engineering:code-review` |

If it is not installed, the five rules below still fully apply. Never let a missing plugin lower the bar.

## The five rules (match-and-refuse, numbered per source)

If you are about to ship any of these, stop and apply the default remedy instead.

**(1) Never ship uncompressed responses over the wire.** A JSON or HTML payload leaving a server or edge function uncompressed pays a bandwidth and latency tax on every request, compounding across every client. **Default remedy:** compress at the edge or server — gzip at minimum, brotli where the runtime supports it — and verify the `Content-Encoding` header actually lands on the response, not just that middleware exists.

**(2) Never write rows one at a time when a batch exists.** A loop issuing one `INSERT`/`UPDATE` per row turns an O(1) round-trip into an O(n) one, and the cost scales silently until a dataset grows. **Default remedy:** batch — a multi-row `INSERT`, a bulk upsert, a single transaction — wherever the driver or ORM exposes one; treat a row-at-a-time write loop found in review as a defect, not a style preference.

**(3) Audit network latency and name the single slowest dependency before optimizing anything else.** Optimizing a fast call while the slow one dominates the waterfall is motion without progress. **Default remedy:** capture a real request waterfall, identify the one dependency that dominates total latency, and fix that one first — re-measure before touching a second thing. This is the rule that keeps rules (1), (2), and (5) from being applied performatively instead of where they matter.

**(4) Update UI optimistically, with reconciliation on failure.** A UI that waits for a round-trip before showing the result of an action feels slow even when the backend is fast. **Default remedy:** apply the change locally the instant the user acts, then reconcile against the server response — roll back and surface the failure state if the write doesn't land. This extends the mobile trio's offline-first default (`agents/react-native-engineer.md`, `agents/ios-engineer.md`, `agents/android-engineer.md`) to the web as the house default, without contradicting it: the same optimistic-then-reconcile shape, one more platform. It also inherits the evidence standard `agents/self-eval-critic.md` already enforces — optimistic UI that reverts on reload is a bug, not a pass, because the local update was never actually reconciled against a persisted write.

**(5) Serve static frontends statically.** Rebuilding or re-rendering a page per visitor when its content doesn't depend on that visitor is paying server cost and latency for nothing. **Default remedy:** ship prerendered/static output for any route with no per-visitor data dependency, and reserve server rendering or edge functions for the routes that genuinely need one.

## The inherited-backend audit (A1-A5, standing)

The five rules above are construction rules — they refuse a pattern *as it is being written*. They cannot see a backend that already exists. These audits are the sweep half: run them over any backend SAEED inherits or has finished building, **without being asked**, on every hire (`/saeed:hire` Phase 3, and Phase 0 the moment a takeover baseline is captured) and on every improvement pass. Each finding is a queue item with a measured before/after, not a note.

**(A1) Audit for queries pulling more than the UI actually needs, and resolve.** A `SELECT *` behind a list view that renders three columns, an endpoint returning a full nested object graph for a card, a joined table nobody reads — each pays serialization, bandwidth, and cache cost forever. **Default remedy:** trace each read path from the rendering component back to the query, project only the columns and rows the surface consumes, and paginate anything unbounded. Where the shape is contractual, the fix belongs in the API contract (`agents/api-designer.md`), not in a client-side filter that discards data it already paid to transfer.

**(A2) Audit for N+1 queries and fix the query, not the symptom.** Rule (2) refuses a row-at-a-time *write*; this is its read-side twin, swept across the existing codebase rather than caught in a diff. **Default remedy:** batch or join at the source. Ownership does not move — findings route to `agents/query-optimization-engineer.md`, which already owns N+1 elimination and its EXPLAIN evidence, and `agents/code-reviewer.md` keeps catching new ones per-diff. This audit exists because neither of those two ever sweeps code that landed before SAEED arrived.

**(A3) Audit that database connections are actually released.** A connection acquired in a handler and never returned on the error path drains the pool under exactly the load where you need it — the failure looks like unexplained latency, then saturation, never like the leak it is. **Default remedy:** every acquisition sits in a scope that releases on both the success and the failure path (context manager, `finally`, framework-managed scope); no long-lived connection is held across an `await` on an unrelated I/O call. Verify against the live pool's in-use count under load, not by reading the code — a leak that only the error path opens is invisible in review. Pool *sizing* under contention stays `agents/query-optimization-engineer.md`'s; this is about connections that were never given back.

**(A4) Audit object storage for orphaned blobs.** An upload whose database row was rolled back, a file whose owning record was deleted without its blob, a half-finished multipart upload — all bill monthly, forever, and quietly become an unaudited data-retention surface as well as a cost one. **Default remedy:** reconcile the bucket against the table that references it in both directions, delete what nothing points at (after confirming the reconciliation is sound — an orphan by a broken join is not an orphan), and close the source: blob lifecycle is transactional with its row, deletes cascade to storage, and abandoned multipart uploads expire by bucket lifecycle rule rather than by hand. The privacy half — retention limits, whether the orphan held personal data — is `agents/compliance-privacy-engineer.md`'s call, not a cost decision.

**(A5) Audit for background jobs silently holding pool connections.** Crons, queue consumers, schedulers, and listeners each hold connections that no request-path metric attributes to them; a pool sized for traffic is then starved by work nobody counted. **Default remedy:** enumerate every scheduled and background worker in the repo — including ones registered by a framework or an extension rather than written by hand — and for each, state the connections it holds and for how long. Anything holding a connection idle between runs is converted to acquire-on-work-release-on-done. The enumeration is the deliverable: an unlisted background job is the finding.

Each audit is N/A-capable, but only in writing and only on the same terms as the canon's scope clause — A4 is N/A with no object storage, A5 with no background workers. "We didn't find any" is a result; "we didn't look" is not.

## Pre-ship checklist

- [ ] No uncompressed response leaves an edge or origin server (rule 1).
- [ ] No write loop issues one row at a time where a batch path exists (rule 2).
- [ ] The single slowest dependency in the request waterfall is named, with a before/after measurement — not a guess (rule 3).
- [ ] Every optimistic UI update reconciles on failure and survives a hard reload (rule 4; `agents/self-eval-critic.md` evidence standard).
- [ ] Every static-content route is served statically, with no needless per-visitor rebuild (rule 5).
- [ ] N+1 queries surfaced during review are routed to `agents/query-optimization-engineer.md`, not silently patched in place.
- [ ] The inherited-backend audit ran, with a written result per item — over-fetching resolved (A1), N+1 sweep routed (A2), connection release verified under load (A3), object storage reconciled (A4), every background worker enumerated with its connection cost (A5) — or an N/A with its reason.

**Gate:** `agents/frontend-performance-engineer.md` measures the before/after numbers this checklist claims — a rule marked satisfied with no re-measured delta is not satisfied. `agents/code-reviewer.md` match-and-refuses the five patterns above when it sees them in a diff. The A1-A5 audit is verdict-bearing the same way: an audit reported with no finding and no evidence of having looked is not an audit, and `agents/self-eval-critic.md` treats it as motion without progress.

## Wiring

- **Owner:** `agents/frontend-performance-engineer.md` — stewards this canon and owns the before/after measurement.
- **Audit owners (A1-A5):** `agents/query-optimization-engineer.md` diagnoses A1-A3 and A5's pool arithmetic; `agents/backend-engineer.md` applies the code fixes and owns blob lifecycle at the write path (A4); `agents/sre-observability-engineer.md` supplies the live pool and worker telemetry A3 and A5 verify against — none of them is code-readable from a diff; `agents/cloud-infra-engineer.md` owns the bucket lifecycle rules that close A4 at the source.
- **Applying class:** `agents/backend-engineer.md`, `agents/frontend-engineer.md`, `agents/edge-serverless-engineer.md`, `agents/api-designer.md`, `agents/query-optimization-engineer.md`, `agents/sre-observability-engineer.md`, `agents/pwa-offline-engineer.md` (rules 4 and 5 are the core of its scope). The mobile trio (`agents/react-native-engineer.md`, `agents/ios-engineer.md`, `agents/android-engineer.md`) gets a one-line cross-reference only — they already carry optimistic UI as native doctrine, so full class membership would restate rule 4 rather than extend it.
- **Gate:** `agents/code-reviewer.md` match-and-refuses the five patterns in a diff; `agents/frontend-performance-engineer.md` supplies the measured before/after this canon's checklist requires.
- **Deliberate exclusions:** render/animation performance stays with `skills/design-excellence/SKILL.md` — folding it in here would create a second home for one rule. N+1-in-review stays a flag-and-route in `agents/code-reviewer.md` rather than a transfer of ownership to this canon; deep query optimization stays with `agents/query-optimization-engineer.md`.

## Attribution

This canon distills, with gratitude, Hayden Smith's five slow-app reasons — the operator-supplied source behind rules (1)-(5) above. Rewritten in house match-and-refuse voice per SAEED's absorption convention; the original ordering is preserved rule-for-rule so a reviewer can map source to canon by number. No verbatim appendix ships here — the source text survives in `.saeed/tasks/cycle-9/spec.md` and the operator's original material.

The A1-A5 inherited-backend audit distills a second operator-supplied source (2026-08-06): five backend audit prompts, absorbed here as standing doctrine rather than prompts the operator has to re-type. Ordering is again preserved item-for-item. A2 is the one item that was already owned — it enters as a sweep with a route, not a second home for N+1.
