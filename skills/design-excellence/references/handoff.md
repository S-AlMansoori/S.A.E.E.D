# Design handoff — a reference design is law (full treatment)

Load this file whenever the task is implementing a reference design: a Figma
file, a mock, a redesign spec, or a build inside an existing design system.
The compact law binds from the canon body even when this file is never
loaded; this file adds the workflow, the verification bar, and the review
shapes to refuse. Distilled from figma-implements-design and
playwright/webapp-testing (see the canon's Attribution).

## The stance: translate, don't reinterpret

A reference design is the brief's most binding form. Your taste is not on
trial — fidelity is. The canon's variance mandate and reflex checks govern
surfaces you *originate*; a handed-off design has already made those calls,
and "improving" it silently is a defect, not initiative.

- Build from the **existing design system's tokens and components** first.
  A new one-off component or hard-coded value where a system equivalent
  exists is a mismatch even when it looks identical today — it will drift.
- Reproduce the reference's spacing, type, and color **by value** (inspect
  the file / tokens), never by eye.
- A deviation you believe is genuinely necessary (an accessibility failure
  in the reference, a state it never designed, an RTL case it ignored) is
  **raised and recorded, never silently applied**. Accessibility and the
  canon's performance guardrails outrank the reference; aesthetics never do.

## Every state the reference implies

The Figma frame usually shows the happy path. The states law still binds:
loading, empty, error, success, offline, hover/focus/active/disabled — build
them all, deriving their look from the reference's own patterns (its
disabled treatment, its error color role) rather than inventing a second
visual language. A reference with no designed error state is a question for
the designer, answered in writing — not a blank you improvise.

## The fidelity pass — verify in a real browser, then self-grade

Before hand-off, not at review:

1. Run the build in a real browser (Playwright or equivalent — the same
   engine the design-reviewer gate will consume screenshots from).
2. Capture the implemented surface **side-by-side with the reference** at
   the reference's own breakpoints — at minimum mobile (~390px), tablet
   (~768px), desktop (~1280px+), plus RTL where the surface is bilingual.
3. Grade your own work: walk the pairs and list every mismatch — spacing,
   type scale, color role, radius, state treatment, layout collapse.
4. **Fix what you find and re-run.** The loop is yours; the gate is not
   your debugger. Hand off only when the remaining deltas are the ones you
   deliberately raised (see above), each with its reason.
5. Attach the evidence: the side-by-side captures and the deviation list
   ride with the change to the `design-reviewer` gate (screenshot-or-block
   already requires the rendered artifact; this names its content for
   handoff work).

## Refuse in review (`design-reviewer` shapes)

- A handoff implemented with no side-by-side evidence at the reference's
  breakpoints — that is "unrenderable" for fidelity purposes: block.
- A one-off component or literal value duplicating an existing system
  token/component.
- A deviation from the reference with no written authorization or recorded
  reason — including "improvements".
- Happy-path-only builds: any state the states law names, missing.
- Fidelity at desktop only — the mobile/tablet/RTL pairs are part of the
  definition of done.
