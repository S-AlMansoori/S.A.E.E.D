---
name: spec-quality
description: SAEED's requirements-layer canon — the ten-category ambiguity taxonomy rated Clear/Partial/Missing, the bounded five-question clarification budget with informed-default Assumptions, answer integration that deletes contradicted text, checklists as unit tests for requirements, and the read-only analysis gate with its requirements-to-tasks coverage table. Applies upstream of orchestration, wherever specs are written.
---

# SAEED Spec-Quality — the absorbed requirements canon

SAEED has absorbed GitHub Spec Kit's requirements-layer doctrine: the ambiguity taxonomy behind
`/speckit.clarify`, the bounded clarification loop, "checklists are unit tests for requirements"
from `/speckit.checklist`, and the read-only cross-artifact audit from `/speckit.analyze`. Their
combined lesson is one sentence: **a requirement is not done when it is written — it is done when
it can fail a test written against its own wording.** This canon makes that test runnable, before
a single ticket is cut.

## Scope / when this applies (and when it does not)

Spec-quality governs the **requirements layer** — specs, stories, and acceptance criteria, however
SAEED authors them (`/saeed:hire` Phase 1, a standalone spec doc, a corpus ingestion). It sits
**upstream of `skills/orchestration-protocol/SKILL.md`**, which begins once tickets and worktrees
exist. Spec Kit's own `specify → plan → tasks → implement` pipeline, its extension-hook mechanism
(`.specify/extensions.yml`), and its CLI/script plumbing are **not** absorbed — SAEED writes specs
and cuts tickets in its own house formats; only the requirements-*quality* doctrine crosses over.

**The task-size applicability ladder** is defined once, in
`skills/engineering-method/SKILL.md` ("The applicability ladder"). Classify the task there; what
each tier binds *in this canon* is:

- **L** — the full audit: the taxonomy pass, the clarification budget, the requirements checklists,
  and the coverage-table analysis gate all bind.
- **M** — a **self-check only**, and only when acceptance criteria are absent or visibly ambiguous;
  no formal checklist file, no analysis-gate report.
- **S** — exempt outright. A trivial or mechanical change does not get a ten-category audit because
  a ticket happens to exist for it.

**The budget never parks a task for an absent operator.** An unanswered clarification question
becomes an **informed default**, recorded in the spec's Assumptions section — never a stalled spec.
Park only a true scope blocker: a decision with no reasonable default, no informed guess, and
material impact on scope or on security/privacy — and park it under the `## Awaiting operator`
convention (`skills/self-governance/SKILL.md`) with the exact blocking question, never by silent
guesswork on a security- or compliance-critical unknown. This is the same never-deadlock guarantee
self-governance states for the rest of the team; spec-quality does not get its own weaker rule.

**Does not apply:** refactors-under-green, mechanical sweeps, and any S-tier change (per the
ladder above); a spec whose acceptance criteria are already testable, unambiguous, and covered by
tasks needs no audit merely because the story exists.

## Invoke the deep skill (when the Skill tool is available to you)

| Task in front of you | Invoke |
|---|---|
| Interactively clarifying a spec, generating a live requirements checklist, or running a cross-artifact consistency pass | GitHub Spec Kit's `/speckit.clarify`, `/speckit.checklist`, and `/speckit.analyze` commands, when installed, for the full interactive loop |

If Spec Kit is not installed, the doctrine below still fully applies. **Never let a missing plugin lower the bar.**

## The ambiguity taxonomy (rated Clear / Partial / Missing)

Before planning, scan the spec against every category below and mark each **Clear / Partial /
Missing**. A Partial or Missing category is a candidate clarification question (see the budget);
a category not worth a question yet is fine to be Partial — deferred, not ignored, and named in
the report.

| Category | What it covers |
|---|---|
| Functional scope & behavior | Core user goals and success criteria; explicit out-of-scope declarations; role/persona differentiation |
| Domain & data model | Entities, attributes, relationships; identity/uniqueness rules; lifecycle/state transitions; volume/scale assumptions |
| Interaction & UX flow | Critical user journeys; error/empty/loading states; accessibility and localization notes (Arabic/RTL is never an afterthought here) |
| Non-functional quality | Performance, scalability, reliability/availability, observability, security/privacy, compliance |
| Integration & external dependencies | External services/APIs and their failure modes; import/export formats; protocol/versioning assumptions |
| Edge cases & failure handling | Negative scenarios; rate limiting/throttling; conflict resolution (e.g., concurrent edits) |
| Constraints & tradeoffs | Technical constraints (language, storage, hosting); explicit tradeoffs or rejected alternatives |
| Terminology & consistency | Canonical glossary terms; avoided synonyms/deprecated terms |
| Completion signals | Acceptance-criteria testability; measurable Definition-of-Done indicators |
| Misc / placeholders | Unresolved TODO markers; ambiguous unquantified adjectives ("robust", "intuitive", "fast") |

A category with no reasonable default and material scope/security impact is a clarification
candidate; a category where any competent build would land the same way regardless of the answer
is not — skip the question, note the assumption.

## The clarification budget (at most 5 questions)

- **Hard cap: 5 questions total** for the whole spec, ranked by **Impact × Uncertainty**. When more
  than five categories are open, keep only the top five.
- **Priority order when ranking ties: scope > security/privacy > UX > technical.** A security
  unknown always outranks a UX preference.
- **Every question is answerable in one of two shapes**: a multiple-choice table (2–5 mutually
  exclusive options), or a short-phrase answer explicitly capped at **≤5 words**. No open-ended
  essay questions.
- **State the recommended answer first**, with one line of reasoning, before the option table —
  the person answering should be able to say "yes" and move on.
- **Everything below the cut line becomes an informed default**, written into the spec's
  **Assumptions** section, never silently assumed and never left as an open question nobody
  answers.

## Answer integration — edit in place, never append-only

- Every accepted answer is merged into the **exact spec section it clarifies** — a functional
  requirement, the data model, a success criterion, an edge case, a terminology entry — not parked
  in a growing Q&A transcript that the rest of the spec silently contradicts.
- Keep a short `## Clarifications` log (`- Q: <question> → A: <answer>`) for the audit trail, but
  the log is a record, not the spec's source of truth — the body text itself changes.
- **If an answer contradicts earlier spec text, delete the contradicted text.** No dangling
  alternative, no "or possibly X" left beside the resolved answer. This is what keeps a spec
  internally consistent as answers arrive instead of accumulating drift.
- Normalize terminology across every touched section in the same pass; if a term changes, note the
  old one once (`(formerly "X")`) rather than leaving two names for one concept.

## Checklists as unit tests for requirements

A requirements checklist tests the **wording**, never the implementation. This is the single most
common failure mode to correct in a reviewer's head: a checklist item is not "verify the button
works" — it is "is the button's required behavior specified clearly enough to test at all?"

- **Banned phrasing:** any item starting "Verify / Test / Confirm / Check that X works / renders /
  navigates / displays correctly" is an implementation test wearing a checklist costume — reject
  it and rewrite it as a requirements question.
- **Required phrasing:** "Are/Is [requirement] defined / specified / consistent / measurable for
  [scenario]?" — every item is a question about the spec's own text.
- **Five quality dimensions, and every item names one:** Completeness, Clarity, Consistency,
  Measurability, Coverage (primary / alternate / exception / recovery / non-functional scenario
  classes each get a coverage check).
- **Traceability floor: at least 80% of items carry a marker** — a spec-section reference or one
  of `[Gap]` / `[Ambiguity]` / `[Conflict]` / `[Assumption]`. An item with no marker is a floating
  opinion, not a requirements test.
- Consolidate near-duplicate items checking the same aspect; collapse more than five low-impact
  edge cases into one combined item rather than padding the list.

## The read-only pre-implementation analysis gate

Before tickets are cut (`the-boss`'s plan sign-off, `team-orchestrator`'s decomposition), run a
**strictly read-only** analysis across the spec (and its plan/tasks if they already exist). This
gate **never edits a file** — it produces a report, and the report is the deliverable.

**Six detection passes:**

1. **Duplication** — near-duplicate requirements; flag the weaker phrasing for consolidation.
2. **Ambiguity** — vague unquantified adjectives, unresolved placeholders (`TODO`, `TKTK`, `???`).
3. **Underspecification** — a requirement with a verb but no object or measurable outcome; an
   acceptance criterion with no testable Given/When/Then shape.
4. **Governance alignment** — a requirement or plan element conflicting with a project constitution
   principle, where one is versioned (`skills/self-governance/SKILL.md` owns that artifact and its
   auto-CRITICAL rule; this pass consults it, never restates it).
5. **Coverage gaps** — a requirement with zero mapped tasks; a task with no mapped requirement; a
   non-functional success criterion requiring buildable work (perf harness, security audit tooling)
   that no task covers.
6. **Inconsistency** — terminology drift across sections; an entity in the plan absent from the
   spec (or the reverse); task-ordering contradictions with no stated dependency; requirements that
   flatly conflict.

**Severity, scoped to this report:** CRITICAL (a governance-principle violation, or a requirement
with zero coverage blocking baseline functionality) · HIGH (a duplicate/conflicting requirement, an
ambiguous security or performance attribute, an untestable acceptance criterion) · MEDIUM
(terminology drift, a missing non-functional task, an underspecified edge case) · LOW (wording,
minor redundancy). HIGH/CRITICAL findings carry proof (quote the spec line) — the same evidence
standard `skills/verification-protocol/SKILL.md`'s anti-noise doctrine holds diff review to,
applied here to spec text instead of a diff.

**The requirements-to-tasks coverage table** is the gate's load-bearing artifact:

| Requirement key | Has task? | Task IDs | Notes |
|---|---|---|---|

`team-orchestrator` **refuses to cut tickets at L-tier without this table filled in** — an empty
or absent coverage table is itself a CRITICAL finding, not a formality to backfill later.

## The spec-of-specs escalation ladder

When a feature is too large for one spec-quality pass to hold in view, decompose **before** writing
any sub-spec — reach for this only after the lighter option (splitting the work into smaller tasks
within one spec) is insufficient:

1. **State the whole feature** in one or two sentences so the decomposition has the full picture.
2. **Identify independent, individually-testable slices** — implementing one slice alone should
   leave something demonstrable.
3. **Draw a sharp scope boundary per slice** — what's in, what's explicitly deferred to a sibling.
4. **Order by dependency**, noting which slices block which; independent slices may proceed in any
   order.
5. **Record it as a durable roadmap** — a plain Markdown table with a stable ID per slice, its
   intent, its scope boundary, its dependencies, and its status.

Each slice then runs its **own** full spec-quality pass (taxonomy, budget, checklist, analysis
gate) independently, small enough to fit in one pass; a slice still too large recurses one level
further with its own roadmap. The roadmap only **names and orders** the slices — it does not design
them, and it does not replace `skills/orchestration-protocol/SKILL.md`'s wave model, which fans out
the *execution* of already-decomposed work; spec-quality's roadmap is the *requirements*-side
decomposition that happens before any wave exists (cross-ref only, not restated either direction).
Every sub-spec names its parent roadmap and entry ID; the roadmap's entry links back to the
sub-spec's path — a plain-text, grep-able, bidirectional convention, no new tooling.

## Pre-flight checklist — before cutting tickets at L-tier

- [ ] Every taxonomy category is rated Clear / Partial / Missing, and every Partial/Missing has a
      one-line reason it was or wasn't worth a clarification question.
- [ ] At most 5 questions were asked; everything else is an informed default in **Assumptions**.
- [ ] Every accepted answer is merged into its exact spec section; no contradicted text survives
      beside it.
- [ ] The requirements checklist has zero implementation-verification-phrased items and ≥80%
      traceability markers.
- [ ] The requirements-to-tasks coverage table is filled in — no unmapped requirement, no
      unexplained unmapped task.
- [ ] Any true scope blocker is parked under `## Awaiting operator` with the exact question, not
      silently guessed.

## Wiring

- **Owner:** `product-engineer` — the taxonomy and clarification budget are this agent's own
  working method, not just a canon it consults.
- **Applying class:** `principal-architect`, `the-boss` (runs the analysis gate at plan sign-off),
  `ux-researcher`, `team-orchestrator` (the coverage-table refusal before cutting tickets).
- **Command:** `commands/hire.md` Phase 1.1, where stories are written.
- **Gate:** `the-boss`'s read-only pre-implementation analysis gate, and `team-orchestrator`'s
  refusal to cut tickets at L-tier without a filled requirements-to-tasks coverage table. A red
  verdict here slots under the existing precedence order in `skills/self-governance/SKILL.md` like
  any other gate — it does not compete with red-gate supremacy or the stricter-verdict rule, and
  skipping it (or misdeclaring a task's tier to dodge it) is gate-weakening, the same untouchable
  every other SAEED gate answers to.
- **Deliberate exclusions:** the execution-stage mechanics (worktrees, wave sequencing, ticket
  queues) stay in `skills/orchestration-protocol/SKILL.md` — spec-quality stops at the requirements
  layer. The constitution artifact itself (versioning, auto-CRITICAL violations) is owned and
  extended in `skills/self-governance/SKILL.md`; this canon's analysis gate consults it and never
  restates its rules. Spec Kit's CLI, extension-hook plumbing, and the specify/plan/tasks/implement
  command pipeline are intentionally not absorbed.

## Attribution

This canon distills, with gratitude, GitHub's **Spec Kit**: the ambiguity taxonomy and its
Clear/Partial/Missing rating discipline (`/speckit.clarify`), "checklists are unit tests for
requirements" (`/speckit.checklist`), the read-only cross-artifact analysis gate and its
requirements-to-tasks coverage table (`/speckit.analyze`), and the spec-of-specs roadmap pattern
for oversized features. When Spec Kit is installed, prefer invoking it directly for the full
interactive loop; this file guarantees the standard when it is not.
