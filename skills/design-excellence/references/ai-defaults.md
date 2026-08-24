# The 2026-06 AI-default delta (full treatment)

Load this file before the plan pass of any surface you originate (it does not
govern faithful handoff work — `references/handoff.md` does). The four rules
bind from the compact block in the canon body even when this file is never
loaded; this file adds the full reasoning and procedure. (Moved here from the
canon body in cycle 13; nothing below was weakened in the move.) The
enforcement home is the `design-reviewer` gate, which carries the blocklist
as a standing review check (cycle 9).

## The named generic-AI-look blocklist

Mid-2026 AI design converges on three looks. Each is legitimate for *some*
brief, and each shows up regardless of subject, which is exactly what makes
them defaults rather than decisions:

1. **Cream editorial** — warm cream ground near `#F4F1EA`, a high-contrast
   serif display, a terracotta accent.
2. **Near-black + one acid accent** — near-black ground carrying a single
   bright acid-green or vermilion.
3. **Broadsheet** — hairline rules, zero border-radius, dense
   newspaper-like columns.

**The brief always wins.** Where the brief pins a visual direction, follow
it exactly, including when it asks for one of these three. Where the brief
leaves an axis free, never spend that freedom on a blocklist look.

**The house register is not exempt.** SAEED's navy `#0A1628` + gold
`#C9A84C` minimalism sits adjacent to look 2 (near-black ground, one warm
accent), and the canon's first-order test already names navy-and-gold as the
finance reflex. The house palette therefore takes the same reflex check as
any other choice: justify it from this brief's subject, or pick something
else. Being the house default is not a justification.

## Plan, then critique the plan — the convergence self-check

Work in two passes before writing any code.

1. **Plan.** Build a compact token system from the brief: **color** (4–6
   named hex values), **type** (2+ roles: a characterful display face used
   with restraint, a complementary body face, a utility face for captions or
   data), **layout** (one-sentence prose concepts plus ASCII wireframes, so
   directions can be compared), and **signature** (below).
2. **Critique.** Review that plan against the brief, part by part. Work
   through a similar prompt for a similar page: **if you arrive somewhere
   similar, it is a default, not a decision** — revise that part, and say
   what you changed and why. Only once the plan survives this pass do you
   write code, following the revised plan exactly and deriving every color
   and type value from it.

Do this planning and iteration in your thinking; show the user ideas only
when confidence is high.

## The signature slot — spend boldness in one place

Every token system carries a **signature**: the single element this surface
will be remembered by, chosen because it embodies the brief. An empty
signature slot means the design has no thesis. Every screen keeps a
**single visual anchor** — two anchors compete, zero is wallpaper.
Everything around the signature stays quiet and disciplined, and any
decoration that does not serve the brief is cut. Before hand-off, apply
Chanel's mirror rule and remove one accessory. Taking no risk is itself a
risk.

## Selector specificity cancels silently

When writing the CSS, structure selector specificity deliberately. A
section-level class and an element-level class that both set the same
property (a `.section` rule and a `.cta` rule each owning vertical padding
or margin) cancel each other out, and the defect is invisible in the
source — it surfaces only as wrong spacing between sections. Give every
spacing property exactly one owning layer.
