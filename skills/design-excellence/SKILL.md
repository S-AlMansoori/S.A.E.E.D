---
name: design-excellence
description: SAEED's absorbed design canon — the enforceable house standard for every user-facing surface. Distills impeccable, gpt-taste, high-end-visual-design, design-taste-frontend, and emil-design-eng into non-negotiable laws for color, type, layout, motion, content, and anti-AI-slop craft, plus the rule to invoke those skills for full depth. Consulted automatically by every UI-touching SAEED agent — no one has to ask.
---

# SAEED Design Excellence — the absorbed canon

SAEED has permanently absorbed a body of elite frontend-design skills. Their laws are now **house standard**: every user-facing surface SAEED designs, builds, reviews, or improves is held to this bar **automatically, without the user asking**. This file is the floor. The named skills are the depth.

Applies to both **registers** — *brand* (marketing, landing, campaign, portfolio: design IS the product) and *product* (app UI, dashboards, tools: design SERVES the product). Identify the register first; both obey the shared laws below.

## Auto-activation (this is not optional)

Any SAEED agent that produces, changes, specs, reviews, or audits a user-facing surface **must apply this canon before it acts** — even when the user never mentioned design. Frontend, mobile, design, design-systems, i18n, PWA, performance, accessibility, UX, and the design-review gate all inherit it.

## Invoke the deep skills (when the Skill tool is available to you)

The canon is self-contained, but the source skills carry far more depth. When they are installed, **invoke the best-fit one via the Skill tool and fold its output into your work** — don't reinvent what it already encodes:

| Task in front of you | Invoke |
|---|---|
| Any holistic design / redesign / polish / critique / audit of an interface | `impeccable` (has sub-commands: `craft`, `shape`, `audit`, `polish`, `bolder`, `distill`, `animate`, `typeset`, `layout`, `clarify`, `harden`…) |
| Award-tier landing / marketing page, AIDA structure, bento, scrolltelling | `gpt-taste` |
| "$150k agency" visual feel: double-bezel surfaces, variance engine, choreography | `high-end-visual-design` |
| Component/dashboard engineering, metric-based rules, hardware-accelerated motion | `design-taste-frontend` |
| Animation, interaction, and the invisible polish that makes UI feel right | `emil-design-eng` |
| Exhaustive, un-truncated code output with no placeholders | `full-output-enforcement` |

If none are installed, the canon below still fully applies. Never let a missing plugin lower the bar.

## First principle — the AI-slop test

If someone could look at the result and say "AI made that" without doubt, it failed. Run the category-reflex check at two altitudes:

- **First-order:** if the theme + palette are guessable from the domain alone (observability → dark blue, healthcare → white + teal, finance → navy + gold, crypto → neon on black), it's the first training-data reflex. Rework.
- **Second-order:** if the aesthetic family is guessable from domain-plus-anti-reference ("fintech but not navy-and-gold → terminal dark", "AI tool but not SaaS-cream → editorial-typographic"), it's the trap one tier deeper. Rework until neither is obvious.

**Variance mandate:** never converge on the same layout or aesthetic twice. Combine layout and texture archetypes deliberately per project; do not default to the first option that comes to mind.

## Absolute bans (match-and-refuse)

If you are about to write any of these, stop and rewrite the element with different structure.

- **Side-stripe borders** — a colored `border-left`/`border-right` > 1px as an accent on cards, alerts, callouts. Use full borders, background tints, or leading icons.
- **Gradient text** — `background-clip: text` over a gradient. Use one solid color; emphasize with weight or size.
- **Default glassmorphism** — decorative blur/glass. Rare and purposeful, or nothing.
- **The hero-metric template** — big number, small label, supporting stats, gradient accent. SaaS cliché.
- **Identical card grids** — same-size cards with icon + heading + text repeated. The generic "3 equal columns" feature row is banned; use zig-zag, asymmetric, or horizontal-scroll instead.
- **Nested cards** — a card inside a card is always wrong.
- **Modal as first thought** — exhaust inline / progressive alternatives first.
- **Banned fonts** — `Inter`, Roboto, Arial, Helvetica, Open Sans. (SAEED house display is Cormorant Garamond; body is DM Sans. Otherwise reach for Geist, Satoshi, Cabinet Grotesk, Outfit, Clash Display, PP Editorial New.)
- **Emojis as UI** — never in code, markup, labels, or alt text. Use Phosphor or Radix icons, or clean SVG.
- **Pure `#000` / `#fff`** — tint every neutral toward the brand hue (OKLCH chroma 0.005–0.01).
- **The AI-purple/neon-glow aesthetic** — no purple button glows, no outer-glow `box-shadow`, no neon gradients. Neutral base + one high-contrast accent.
- **Cheap meta-labels** — "SECTION 01", "QUESTION 05", "ABOUT US" eyebrows that add nothing. Remove them.
- **Em dashes in UI copy** — and no `--`. Use commas, colons, semicolons, periods, or parentheses.
- **`h-screen` for full-height sections** — use `min-h-[100dvh]` (prevents iOS Safari viewport jump).
- **Generic content** — "John Doe", "Acme"/"Nexus", round fake numbers (99.99%, 50%), filler verbs ("Elevate", "Seamless", "Unleash", "Next-Gen"), Unsplash links. Use realistic names, organic numbers (47.2%), invented contextual brands, concrete verbs, `picsum.photos/seed/{keyword}/…`.

## Color

- Work in **OKLCH**. Reduce chroma as lightness nears 0 or 100 (high chroma at the extremes looks garish).
- Pick a **color strategy** before picking colors: *Restrained* (tinted neutrals + one accent ≤10%; product default) · *Committed* (one saturated color carries 30–60%) · *Full palette* (3–4 named roles) · *Drenched* (the surface IS the color). The "one accent ≤10%" rule is Restrained only — the others exceed it on purpose.
- Max one accent for Restrained work; saturation < ~80% unless the strategy is deliberately Committed/Drenched.
- One palette per project — don't drift between warm and cool grays. Tint shadows toward the background hue; never harsh `rgba(0,0,0,0.3)`.
- SAEED house accent is gold `#C9A84C` over navy `#0A1628` — used with restraint (gold is an accent, not a flood), and only when the scene sentence and reflex check don't make navy-and-gold the obvious training-data answer for the domain.

## Theme — light vs dark is never a default

Before choosing, write **one sentence of physical scene**: who uses this, where, under what ambient light, in what mood. If the sentence doesn't force the answer, add detail until it does. "Observability dashboard" forces nothing; "SRE glancing at incident severity on a 27-inch monitor at 2am in a dim room" forces dark. Run the sentence, not the category.

## Typography

- Hierarchy through **scale + weight contrast** (≥1.25 ratio between steps) — never a flat scale. Control emphasis with weight and color, not only size.
- Cap body line length at **65–75ch**.
- **Hero H1: 2–3 lines maximum, never 4–6.** If it wraps long, widen the container (`max-w-5xl`/`6xl`) and shrink the size (`clamp(3rem, 5vw, 5.5rem)`). A 6-line heading is a catastrophic failure.
- Serif for editorial/brand display only; **never serif on a dashboard/technical UI** (use a Sans + Mono pairing there).
- Arabic typography gets equal care: correct display + body faces, line height, and letterforms — not a Latin afterthought.

## Layout & spatial rhythm

- **Vary spacing for rhythm** — identical padding everywhere is monotony. Use **macro-whitespace**: `py-24`–`py-40` between major sections so they read as distinct chapters.
- **Break the center-bias** — don't default to centered hero + symmetric 3-column grids. Reach for split-screen, left-content/right-asset, asymmetric whitespace, bento, masonry, Z-axis cascade.
- **Cards are the lazy answer** — use them only when elevation genuinely communicates hierarchy. In dense/data UIs prefer `border-t` / `divide-y` / negative space over boxing everything.
- **Bento grids:** apply `grid-flow-dense`; interlock `col-span`/`row-span` so there are **zero dead cells**. 3–5 intentional cards beat 8 messy ones. Put titles/descriptions outside and below the card for a gallery feel.
- **Double-bezel (nested enclosure)** for premium surfaces: an outer shell (subtle bg, hairline `ring-1`, small padding, large radius `rounded-[2rem]`) around an inner core with its own bg, inset highlight, and a concentrically smaller radius.
- **Grid over flex-math** — use CSS Grid (`grid-cols-*`), not `w-[calc(33%-1rem)]`. Contain pages with `max-w-7xl mx-auto` (or `max-w-[1400px]`).
- **Mobile collapse is mandatory:** any asymmetric layout above `md:` falls back to single-column `w-full px-4 py-8` below 768px. Remove rotations/negative-margin overlaps on mobile.

## Motion (Emil's framework)

1. **Should it animate at all?** Actions done 100+×/day (keyboard shortcuts, command palette) → no animation, ever. Frequent (hover, list nav) → minimal. Occasional (modals, toasts) → standard. Rare/first-run → can delight.
2. **What's the purpose?** Every animation answers spatial consistency, state indication, explanation, feedback, or preventing a jarring change. "Looks cool" on a frequently-seen element is not a purpose.
3. **Easing.** Entering/exiting → **ease-out**. Moving/morphing on-screen → ease-in-out. Hover/color → ease. Constant (marquee/progress) → linear. **Never `ease-in` for UI** — it feels sluggish at the moment the user is watching. Use strong custom curves, not the weak built-ins: `--ease-out: cubic-bezier(0.23, 1, 0.32, 1)`; `--ease-drawer: cubic-bezier(0.32, 0.72, 0, 1)`.
4. **Duration.** Button press 100–160ms · tooltip 125–200ms · dropdown 150–250ms · modal/drawer 200–500ms. **Keep UI animation < 300ms.**
5. **Physical honesty.** Nothing appears from nothing — enter with `scale(0.95) + opacity` and a gentle fade-up, not `scale(0)`. Buttons respond to press (`:active` → `scale(0.97)` / `-translate-y-[1px]`). Popovers scale from their trigger; modals stay centered.
6. **Spring where it fits** — `type: "spring", stiffness ~100, damping ~20` over linear easing for interactive elements; stagger list/grid reveals rather than mounting all at once.

## Performance guardrails (never traded away)

- **GPU-safe only:** animate `transform` and `opacity`. Never animate `top`/`left`/`width`/`height`. `will-change: transform` sparingly, on actively animating elements only.
- **No scroll-listener animation:** use `IntersectionObserver` / `whileInView`, never `window.addEventListener('scroll')` for reveals.
- **`backdrop-blur` only on fixed/sticky** elements (navbars, overlays) — never on scrolling content (continuous GPU repaints).
- **Grain/noise** only on a `fixed inset-0 z-50 pointer-events-none` pseudo-element — never on scrolling containers.
- **Z-index discipline:** reserve z-indexes for systemic layers (sticky nav, modal, overlay, tooltip); no arbitrary `z-[9999]`.
- Isolate perpetual/infinite animations in their own memoized client component; never re-render the parent layout. Verify a 3rd-party lib exists in `package.json` before importing it.

## Content realism & interactive states

- Realistic names, organic messy numbers, invented contextual brand names, concrete copy. Phosphor/Radix icons (standardize `strokeWidth`), never emoji or the SVG "egg" avatar.
- **Every surface ships all states:** loading (skeletons matching layout, not spinners), empty (composed, tells the user how to fill it), error (inline, specific), success, and offline. A static happy-path only is incomplete.
- Forms: label above input, error text below, sensible gap.

## Bilingual / RTL is first-class

- RTL is a real layout, not a mirror hack: **logical properties** (`inline-start`/`inline-end`, `ms-*`/`me-*`), never hard-coded left/right. Test with real Arabic content and long strings.
- Handle mixed-direction runs (Arabic + Latin + numbers) correctly; format dates/numbers/currency by locale (Hijri/Gregorian, numerals).
- Every user-facing surface works, and looks intentional, in both directions.

## Pre-flight checklist — the last filter before hand-off / review

- [ ] Register identified; the AI-slop test passes at both altitudes (domain reflex avoided).
- [ ] No absolute-ban pattern present (fonts, emoji, gradient text, side-stripes, nested cards, hero-metric, meta-labels, em dashes, pure black/white, AI-purple glow, `h-screen`, generic content).
- [ ] Color strategy chosen deliberately; OKLCH; tinted neutrals; one palette; accent used with restraint.
- [ ] Theme justified by a concrete scene sentence.
- [ ] Type scale has real contrast; hero is 2–3 lines; body ≤75ch; Arabic type cared for.
- [ ] Layout breathes (`py-24`+), varies rhythm, breaks center-bias; bento has zero dead cells; cards earn their elevation.
- [ ] Motion passed the "should it animate?" gate; ease-out/custom curves; <300ms; `transform`/`opacity` only.
- [ ] All states present (loading/empty/error/success/offline); realistic content.
- [ ] RTL correct and tested; mobile collapses to `w-full px-4`; `min-h-[100dvh]`; blur only on fixed layers.

A user-facing change is **not done** until it passes this checklist and the `design-reviewer` gate.

## Attribution

This canon distills, with gratitude, the enforceable rules of the **impeccable** (Apache-2.0, based on Anthropic's frontend-design skill), **gpt-taste**, **high-end-visual-design**, **design-taste-frontend**, **emil-design-eng** (Emil Kowalski's design-engineering philosophy — [animations.dev](https://animations.dev/)), and **full-output-enforcement** skills. When those skills are installed, prefer invoking them for their full depth; this file guarantees the standard when they are not.
