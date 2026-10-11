# Owner preferences — durable, dated, scoped

How the plugin's owner wants the team to work. Each entry: what, since when (dated evidence), scope, status, and the canon that already enforces it where one does — this file never restates that canon's rule, it records the operator's choice and points at the home.

Status words: `current` · `current (secondary evidence)` — the operator's words survive only as a quote inside an assistant-written record · `superseded` — see `supersession-and-coverage.md`.

## Contents

- P-01 Absorb what the operator adopts
- P-02 Capability first, manual last
- P-03 Run until genuinely done, and keep the operator informed
- P-04 Evidence over claims; independent audits on request
- P-05 Ask, don't assume — where the operator says so
- P-06 Model routing
- P-07 Collaboration roster and ownership
- P-08 Publishing approvals are scoped
- P-09 Languages
- P-10 Design latitude and preservation
- P-11 Quality bar for new products
- P-12 Platform and testing defaults
- P-13 Brand and attribution

## P-01 Absorb what the operator adopts

When the operator explicitly asks for shared material to be absorbed ("add this to SAEED", "absorb these"), or it falls within a bounded consolidation the operator directed, fold its new part into the canon that owns its axis, so it binds on every hire without being re-typed: coverage-audit against existing canon first, distill only the delta, credit the source in that canon's Attribution. Everything else the operator shares — links, posts, transcripts, skills — stays a **reference** in the catalogue until the operator adopts it (rule 7).

- Evidence: 2026-07-25 ("absorb skills such as … and these concepts"; "research the best and latest claude skills … absorb them"), 2026-08-06 ("add this to Saeed", "add this", "here are some more tips to absorb", "add a Lottie expert"), 2026-10-11 (this bounded consolidation; the operator's independent review narrowed adoption to explicit requests).
- Home: `skills/canon-craft/SKILL.md`, `skills/continuous-improvement/SKILL.md`. Landing record: the "already absorbed" table in `reference-catalogue.md`.
- Status: current.

## P-02 Capability first, manual last

Before handing the operator a manual step, run the handover ladder; for owner-gated steps that truly need a human, give runnable commands, not prose.

- Evidence: 2026-07-23, 2026-08-07 ("for owner gated … give me runnable commands needed").
- Home: `skills/handover-protocol/SKILL.md`. Status: current.

## P-03 Run until genuinely done, and keep the operator informed

Improvement loops run to honest convergence ("keep looping until the app is immaculate"); delegated tasks are carried through to completion with progress reported, not abandoned at the first green check.

- Evidence: 2026-07-27, 2026-09-12, 2026-10-11 (carry requested tasks through completion and keep the operator informed — this part survived the same message's later ownership change, see P-07).
- Home: `skills/continuous-improvement/SKILL.md` (convergence is honest — no invented busywork). Status: current.

## P-04 Evidence over claims; independent audits on request

Nothing is reported done, tested, submitted or contributed without evidence. When the operator asks for an additional audit after an existing one, it runs as a separate reviewer with its own verdict — never the author grading itself.

- Evidence: 2026-10-10 (an additional independent audit after the existing audit, operator kept informed; the project it named needs context), 2026-10-11.
- Home: `skills/verification-protocol/SKILL.md`. Status: current.

## P-05 Ask, don't assume — where the operator says so

The operator has twice told the team not to fill gaps with its own defaults on a project.

- Evidence: 2026-08-21 ("interview me for any information needed"), 2026-10-03 ("do not make any assumptions, ask me") — two different projects.
- Scope: those projects, and any project where the operator says it again — recorded in that project's spec or `.saeed/`.
- Home: the ask-me exception in `skills/spec-quality/SKILL.md` (ranked rounds of at most five questions; parked, not defaulted, when the operator is absent). Status: current.

## P-06 Model routing

Use the best available models, but the operator — not this file — sets the routing, and it changes with releases.

- 2026-07-23 (primary): a Fable-tier orchestrator, Opus for main tasks, Sonnet for basic tasks.
- 2026-09-25 (secondary — the operator's words quoted in an assistant-written changelog on an unmerged branch): "opus currently beats fable"; "keep only orchestrator as fable for now". Consistent with the primary July instruction. It replaces only an assistant memory note (also secondary) that had widened Fable to every heavy-reasoning subagent; secondary evidence never supersedes primary.
- Project-scoped model instructions stay with their project and never become a house mandate.
- Home: `model-scout` owns `model:` frontmatter. Status: current.

## P-07 Collaboration roster and ownership

As of 2026-10-11:

- **Claude** owns implementation, builds and testing of the operator's existing app projects.
- **dot** (the OpenAI agent) advises, audits, and follows through on App Store Connect requests. A **dot-only** build workflow applies only to an app the operator specifically designates for it; it never pulls an existing Claude-owned app back.
- **Grok** stays in the collaboration roster through a supported channel. Share with it only what the task needs.
- **Codex** is in regular use alongside Claude (2026-09-25, secondary evidence).
- Work across several apps gets **one handover prompt per app**, never one blended prompt.
- Projects that name their own coordination board follow it; its rules are read from that project at the time of work and are not recorded here.
- Evidence: 2026-10-09, 2026-10-11. Superseded: the earlier same-day assignment of overall ownership to dot (see the trail). Status: current.

## P-08 Publishing approvals are scoped

"Push it", "merge to main", "make sure it is live", "commit and push" have been given many times; each covered its own action and the same task's steps it named — never a later, different push. Explicit ongoing grants the operator scoped stand within their scope and conditions wherever they were given: a scheduled steward task that keeps the repository in sync when gates are green is one example; an in-session "commit and push this after validation and review" is another, covering that task once its conditions are met. No grant is widened by inference (rule 3).

- Evidence: 2026-07-15, 2026-07-26, 2026-08-06, 2026-09-03, 2026-10-11. Home: `skills/handover-protocol/SKILL.md` safety carry-over. Status: current.

## P-09 Languages

User-facing products ship Arabic and English unless a project brief says otherwise; the Arabic company name is `نبض` and is never transliterated (`skills/attribution/SKILL.md`). Wider App Store localization is decided per project. An isolated 2026-10-09 "English throughout" belongs to a project that cannot be identified from the evidence and is **not** generalized.

- Home: `i18n-localization-engineer`, `skills/design-excellence/SKILL.md` RTL laws. Status: current.

## P-10 Design latitude and preservation

- Each website or project may carry **its own design language**; do not force child projects into a parent's system (2026-10-11).
- Extending an existing product **preserves its established design** — adding projects to the portfolio sites keeps their design (2026-10-11), and a 2026-10-03 correction restored an existing product's themes and motion rather than redesigning it.
- A style chosen "for this one" stays with that project.
- Home: `skills/design-excellence/SKILL.md` for the craft bar. Status: current.

## P-11 Quality bar for new products

Substantial functionality and a distinctive, original design — not a thin clone (2026-10-11). The operator's message attributed a "built from scratch" rule to Apple; that attribution is an unverified external-policy claim, not a confirmed review rule. Status: current.

## P-12 Platform and testing defaults

- Hosting baseline is Cloudflare + Supabase; if another provider would serve better, **recommend with a plan** rather than switching (2026-07-23).
- Use the iOS Simulator for testing and documentation screenshots when it is available (2026-07-23, 2026-10-11) — without disturbing a simulator another session is driving.
- Status: current.

## P-13 Brand and attribution

Deliverables carry the NABAD credit per `skills/attribution/SKILL.md`; product sites credit Nabad rather than a personal name (2026-07-20). Status: current.
