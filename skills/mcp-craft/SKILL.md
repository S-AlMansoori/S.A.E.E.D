---
name: mcp-craft
description: SAEED's MCP-server build canon — quality measured by LLM task success with a shipped ten-question agentic eval, API-coverage tool design, service_action_resource naming, pagination and truncation contracts, dual JSON/Markdown responses, actionable errors, transport defaults, and MCP-specific security hardening. Consulted whenever SAEED designs, builds, or reviews an MCP server or agent tool surface.
---

# SAEED MCP-Craft — the absorbed canon

SAEED has absorbed Anthropic's `mcp-builder` doctrine: an MCP (Model Context
Protocol) server is not graded by how many endpoints it wraps — it is graded
by **whether an LLM with only the server's tools can accomplish real tasks.**
A comprehensive server whose tools confuse the model is a worse server than a
narrow one whose tools it uses correctly. This file makes that bar concrete:
naming, transport, pagination, response shape, errors, and MCP-specific
security, ending in a shipped eval instead of a vibe.

## Scope — when this applies

Binds by **artifact type: any MCP server SAEED designs, builds, reviews, or
exposes tools through** — a new server, a new tool added to an existing
server, or a review of a third-party MCP server before it is wired in.

**Does NOT apply, and that is the point:** this canon binds only when the
work in front of you builds, changes, or vets an MCP server — no such
artifact, no gate. It costs **zero overhead** on every other task: its
carriers consult it when MCP work appears and otherwise never reach for it,
and nothing here binds a task that touches no MCP surface. It is absorbed
ahead of demand on purpose: the doctrine is in place the moment the first
MCP task lands, instead of costing a research-and-draft cycle at the point
it is actually needed.
General web/app hardening, generic code-quality review, and the task-size
ladder are **not** re-derived here — see Cross-references.

## Invoke the deep skills (when the Skill tool is available to you)

| Task in front of you | Invoke |
|---|---|
| Building, reviewing, or evaluating an MCP server (TypeScript or Python) | `anthropic-skills:mcp-builder` — its bundled reference guides and eval harness (`scripts/evaluation.py`), invoked for full depth, never vendored |
| Checking the wire protocol itself (transports, tool/resource/prompt shapes) | the MCP specification at `modelcontextprotocol.io/specification` (fetch the `.md` page; a live source, re-check rather than memorize) |

If none are installed, the canon below still fully applies. Never let a
missing plugin lower the bar.

## Quality = LLM task success, not endpoint count

The measure of an MCP server is not how comprehensively it implements the
underlying API — it is how well its tool descriptions, schemas, and error
messages let an LLM with **no other context** answer realistic, difficult
questions using only those tools.

**Every server ships with a 10-question agentic eval, before it is
considered done:**

- **Independent** — no question depends on another's answer or on a prior
  write.
- **Read-only / non-destructive / idempotent** — the eval never mutates
  state to reach an answer.
- **Multi-hop and complex** — requires multiple tool calls (potentially
  dozens), not a single lookup; not solvable by pasting a keyword from the
  target content into a search tool.
- **Stable** — answers come from closed/historical data, never a live count
  that will drift ("open issues right now" is a bad question; "the bug
  closed in March 2024 with the most reopens" is a good one).
- **String-verifiable** — a single value (name, ID, count, date, boolean)
  checkable by direct string comparison, never a list or free text whose
  order/format could vary.

Author the ten questions by inspecting tools and exploring content
**read-only**, solving each yourself first to pin the verified answer, then
ship them as an `<evaluation>` XML file of `<qa_pair>` elements (question +
answer) in the source's convention, run through its runner
(`scripts/evaluation.py`, stdio/SSE/HTTP transports supported). Flag and
drop any pair that turns out to need a write or destructive call.

**Thresholds follow `skills/verification-protocol/SKILL.md`:** treat the
eval as a capability eval at `pass@k` during development (any of k runs
succeeds), and require `pass^k` (all k runs succeed) before a
release-critical server ships. A server with no eval evidence is not done —
the same "verification over vibes" standard the rest of SAEED holds.

## API-coverage over workflow, by default

Prefer **comprehensive coverage of the underlying API's endpoints** over a
handful of bespoke workflow tools — coverage gives the calling agent the
flexibility to compose operations the tool author didn't anticipate. Reach
for a higher-level workflow tool only where a specific, frequent task is
demonstrably clumsy to compose from primitives, and keep both available
rather than replacing one with the other. When in doubt, cover the API.

## Stack default

- **Language:** TypeScript, using the official MCP TypeScript SDK's modern
  `register*` API (`registerTool`, `registerResource`, `registerPrompt`) —
  never the deprecated `server.tool()` / manual handler registration. Python
  (FastMCP) is the accepted alternative where the surrounding codebase is
  already Python.
- **Transport:** **streamable HTTP, stateless JSON**, for remote/multi-client
  servers — simpler to scale than a stateful session. **stdio** for local,
  single-client, command-line integrations (and it must log to stderr, never
  stdout, since stdout is the protocol channel). **SSE is deprecated** —
  do not choose it for new servers.
- **Server naming:** `{service}-mcp-server` (TypeScript, hyphenated) or
  `{service}_mcp` (Python, underscored) — general, descriptive, no version
  number baked into the name.

## Tool naming: `{service}_{action}_{resource}`

`snake_case`, action-oriented, service-prefixed even for a single-service
server (a calling agent may have several MCP servers loaded at once and
names collide): `github_create_issue`, `slack_send_message`, never a bare
`create_issue`. Keep each tool focused and atomic — one action, one
resource — and supply **tool annotations** so the client can reason about
risk without calling the tool: `readOnlyHint`, `destructiveHint`,
`idempotentHint`, `openWorldHint`. Annotations are hints, not a security
control — never let an annotation substitute for real authorization.

## Pagination and truncation contracts

Any tool that lists or searches:

- **Always respects a `limit` parameter**, defaulting to 20–50 items, never
  loading an entire result set into memory to satisfy one call.
- **Returns pagination metadata alongside the data**: `total`, `count`,
  `offset`, `has_more`, and `next_offset` (or a cursor) when more pages
  exist — so the calling agent knows to page rather than assume completion.
- **Guards a character-limit ceiling** on the serialized response (the
  source's convention: a `CHARACTER_LIMIT` constant, e.g. 25,000 chars); over
  the limit, truncate the payload, set a `truncated: true` flag, and say so
  in a `truncation_message` that names the escape hatch (narrow the filter,
  pass `offset`) — a silent truncation is a worse failure than a smaller
  page.

## Dual response formats: JSON and Markdown

Every data-returning tool supports a `response_format` parameter
(`json` | `markdown`, Markdown the human-readable default):

- **JSON** — complete, structured, consistent field names/types; for
  programmatic composition by the calling agent or a downstream tool.
- **Markdown** — headers/lists for scannability, timestamps rendered
  human-readable, display names shown with IDs in parentheses, verbose
  metadata omitted. Use `structuredContent` (modern SDK feature) alongside
  the text block so clients that understand structured output get it
  without losing the readable form for clients that don't.

## Actionable error messages

Report tool failures inside the result object (`isError: true` +
content), never as a bare protocol-level error the agent can't act on.
Every error message **names the next step**, not just the failure:
`"Error: Rate limit exceeded. Wait 30s before retrying"`, not
`"Error: 429"`. Never expose internal stack traces, file paths, or
implementation details in a client-facing error — log those server-side
instead (this is the same generic-error discipline
`skills/app-hardening/SKILL.md` holds for the product surface at large; this canon states it for the tool
boundary only, and does not restate the rest of that checklist).

## Phase-1 fetch-live-docs rule

Before writing a line of server code, fetch the **live** MCP specification
(`modelcontextprotocol.io/sitemap.xml`, then the relevant `.md` pages) and
the live SDK README (TypeScript or Python) rather than relying on training
data — both surfaces move faster than model knowledge, and a server built
against a stale mental model of the SDK ships broken registration calls.
Same rule for the target service's own API docs: fetch current pages, don't
assume yesterday's endpoint shapes.

## MCP-specific security (scoped narrowly — not app-hardening's job)

This canon owns only the hardening that is **specific to the MCP transport
boundary**. General input validation, secrets handling, rate limiting, and
the rest of the product-hardening checklist are
`skills/app-hardening/SKILL.md`'s job and `appsec-engineer`'s gate — cross-referenced here, not restated:

- **Token-audience validation** — for OAuth-secured servers, accept only
  access tokens explicitly intended for *this* server; a token valid
  elsewhere is not valid here.
- **DNS-rebinding protection** — for streamable-HTTP servers running
  locally, validate the incoming `Origin` header on every connection.
- **Loopback binding** — bind local HTTP servers to `127.0.0.1`, never
  `0.0.0.0`, so the server isn't reachable from other hosts on the network.

The **consumer-side** question — whether to trust and enable a *third-party*
MCP server at all — is supply-chain review, and stays where it already
lives: `skills/agentic-security/SKILL.md` ("Untrusted inputs to the
workflow itself" → the supply-chain bullet) — cross-ref, no restatement.

## Cross-references (never restated here)

- General app-layer hardening (rate limiting, secrets, generic errors,
  admin lockdown) → `skills/app-hardening/SKILL.md`, gated by
  `appsec-engineer`.
- Third-party MCP server supply-chain review (should we enable this at
  all?) → `skills/agentic-security/SKILL.md` ("Untrusted inputs to the
  workflow itself" → the supply-chain bullet).
- Code-quality review of the implementation diff (DRY, error-handling
  consistency, type coverage) → `code-reviewer`'s standing review lenses —
  Phase-3 review content from the source is **not** duplicated here.
- Eval pass/fail thresholds (`pass@k` vs `pass^k`) →
  `skills/verification-protocol/SKILL.md`.
- Whether this task is S/M/L and which gates therefore bind →
  `skills/engineering-method/SKILL.md` ("The applicability ladder").

## Pre-ship checklist — before an MCP server or new tool lands

- [ ] Tool names are `{service}_{action}_{resource}`, snake_case, annotated
      (`readOnlyHint`/`destructiveHint`/`idempotentHint`/`openWorldHint`).
- [ ] Stack matches the default (TypeScript + streamable-HTTP-stateless, or
      stdio for local) or the deviation is justified in the ticket.
- [ ] Every listing/search tool respects `limit`, returns `has_more` +
      `next_offset`/cursor, and truncates over the character ceiling with a
      `truncation_message`.
- [ ] Every data tool supports both JSON and Markdown `response_format`.
- [ ] Every error path returns an actionable message with no internal
      leakage.
- [ ] MCP-specific security items are checked (token-audience,
      DNS-rebinding, Origin validation, loopback binding) where applicable
      to the transport chosen.
- [ ] The live MCP spec and SDK docs were fetched, not assumed from memory.
- [ ] The 10-question agentic eval exists, was solved by the author first,
      and clears its threshold (`pass@k` in development, `pass^k` before a
      release-critical ship).
- [ ] `code-reviewer` has reviewed the diff under its standing lenses.

## Wiring

- **Owner:** `api-designer` — stewards this canon, designs the tool
  surface, owns the naming/pagination/response contracts.
- **Applying class:** `backend-engineer` (implementation), `ai-systems-engineer`
  and `llm-engineer` (agent-facing tool design and eval authoring),
  `edge-serverless-engineer` (streamable-HTTP deployment), `appsec-engineer`
  (the MCP-specific security section only — general hardening stays theirs
  via `skills/app-hardening/SKILL.md`).
- **Gate:** the 10-question agentic eval (`pass^k` for a release-critical
  server, per `skills/verification-protocol/SKILL.md`) plus `code-reviewer`
  on the diff. A red verdict from either blocks per the ordinary red-gate
  rule; there is no separate arbitration path.
- **Deliberate exclusions, with reasons.** Phase-3 generic code-quality
  review is not re-specified here — it is `code-reviewer`'s standing job
  (the code-review gate's four check classes — N+1 queries, injection
  risks, missing edge cases, error-handling gaps — already cover it).
  General app-hardening is
  not re-specified here — a server that also serves HTTP still owes
  `skills/app-hardening/SKILL.md`'s full pre-ship checklist; this canon only adds the
  transport-specific items on top. Consumer-side review of *other people's*
  MCP servers is `skills/agentic-security/SKILL.md`'s supply-chain rule, not this
  canon's.

## Attribution

This canon distills, with gratitude, Anthropic's **`mcp-builder`** skill
(the four-phase workflow, the MCP best-practices reference, the Node and
Python implementation guides, and the evaluation guide with its runner
script) and the public **Model Context Protocol specification**
(`modelcontextprotocol.io`). When `anthropic-skills:mcp-builder` is
installed, prefer invoking it for full implementation depth; this file
guarantees the standard when it is not.
