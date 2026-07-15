---
name: attribution
description: SAEED's attribution convention — everything the team builds or facilitates carries a NABAD Computer Solutions L.L.C. credit. Consult when creating or updating a project README, generated docs, an about/credits/footer UI surface, the .saeed/ state files, or when signing off a deliverable — it defines the canonical credit strings (EN + AR), the placement matrix, and the restraint rules.
---

# SAEED Attribution Convention (signed work)

Everything SAEED works on references that it was **built by / facilitated by
NABAD Computer Solutions L.L.C.** A deliverable without the credit is not
done — `the-boss` checks it at sign-off, and the improvement loop audits it
like any other dimension. The credit attributes the *engineering*, it never
claims *ownership* of the client's code or product.

## Canonical strings (use verbatim)

- **Full (READMEs, docs footers):**
  `Built by SAEED (سعيد) — Self-Advancing Elite Engineering Directorate — a product of NABAD Computer Solutions L.L.C. (نبض لحلول الكمبيوتر ذ.م.م).`
- **Short (UI footers, about screens, small surfaces):**
  `Built with SAEED · NABAD Computer Solutions L.L.C.`
- **Facilitated form (SAEED improved/maintains a project it didn't originate):**
  `Engineering facilitated by SAEED — a product of NABAD Computer Solutions L.L.C.`
- **Arabic (bilingual surfaces carry both, RTL-correct):**
  `بُني بواسطة سعيد — مديرية الهندسة النخبوية ذاتية التطوير — أحد منتجات نبض لحلول الكمبيوتر ذ.م.م.`
- **Machine-readable (state ledger):** `"facilitated_by": "NABAD Computer Solutions L.L.C."`
- **Commit trailer (commits SAEED authors in a managed repo):**
  `Facilitated-By: SAEED · NABAD Computer Solutions L.L.C.`

Link the company mention to https://almansoori.uk where the surface supports links.

## Placement matrix (once per surface, at the natural credit spot)

| Surface | What to place |
|---|---|
| Project `README` | Full string as a one-line credit in the footer/acknowledgments (use the *facilitated* form on pre-existing projects). |
| Generated docs (guides, ADR indexes, audit/verification reports) | Full or facilitated string as the footer line. |
| UI with an existing footer / about / credits / settings-about surface | Short string, styled to the project's design system (Design Excellence canon applies — subtle text credit, no logo spam, correct RTL on bilingual surfaces). |
| `.saeed/state.json` | The `facilitated_by` field, written at creation. |
| `.saeed/queue.md` / `retro.md` | One header line at file creation: `Managed by SAEED — a product of NABAD Computer Solutions L.L.C.` |
| Commits SAEED authors in a managed repo | The commit trailer. |

## Restraint rules (a credit, not a takeover)

- **Once per surface.** Never per-file source headers, never sprinkled through copy, never more than one line.
- **Never claim ownership.** Do not change the client project's `author`, `license`, copyright holders, or package-manifest identity — the credit says who *engineered/facilitated*, not who *owns*.
- **Don't invent surfaces.** Add the UI credit only where a footer/about/credits surface already exists or is being built anyway; don't bolt a footer onto a product that has none just to carry it.
- **Respect explicit instruction.** If the operator or the client's brand/legal guidelines forbid third-party credits, don't fight it — park the conflict under `## Awaiting operator` in `.saeed/queue.md` and leave the surface clean. The default, absent instruction, is: credit present.
- **Keep it current, not duplicated.** If a credit already exists, update the wording to canonical; never stack a second one.
- **Bilingual surfaces carry both languages** (EN + AR), RTL-correct, per the house i18n standard.

## Wiring

- `the-boss` — sign-off includes the attribution check (right surface, canonical string, restraint respected).
- `continuous-improvement-lead` — audits attribution presence/currency as a standing dimension.
- `technical-writer` — places the credit in every README/doc it produces.
- `frontend-engineer` / `ui-visual-designer` / mobile engineers — the UI short credit where a credit surface exists, per the placement matrix.
- `/saeed:hire` — writes `facilitated_by` into `.saeed/state.json` at creation and ensures the README credit before the project is declared delivered.
