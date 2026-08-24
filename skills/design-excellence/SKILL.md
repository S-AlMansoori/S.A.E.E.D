---
name: design-excellence
description: SAEED's absorbed design canon — the enforceable house standard for every user-facing surface. Distills impeccable, gpt-taste, high-end-visual-design, design-taste-frontend, and emil-design-eng into non-negotiable laws for color, type, layout, motion, content, trust, and anti-AI-slop craft, plus the rule to invoke those skills for full depth. Consulted automatically by every UI-touching SAEED agent — no one has to ask.
---

# SAEED Design Excellence — the absorbed canon

SAEED has permanently absorbed a body of elite frontend-design skills. Their laws are now **house standard**: every user-facing surface SAEED designs, builds, reviews, or improves is held to this bar **automatically, without the user asking**. This file is the floor. The named skills are the depth.

Applies to both **registers** — *brand* (marketing, landing, campaign, portfolio: design IS the product) and *product* (app UI, dashboards, tools: design SERVES the product). Identify the register first; both obey the shared laws below.

## Auto-activation (this is not optional)

Any SAEED agent that produces, changes, specs, reviews, or audits a user-facing surface **must apply this canon before it acts** — even when the user never mentioned design. Frontend, mobile, design, design-systems, i18n, PWA, performance, accessibility, UX, and the design-review gate all inherit it.

## Invoke the deep skills (when the Skill tool is available to you)

The canon is self-contained; the source skills carry the depth. When installed, **invoke the best-fit one via the Skill tool and fold its output in** — don't reinvent what it encodes:

| Task in front of you | Invoke |
|---|---|
| Any holistic design / redesign / polish / critique / audit of an interface | `impeccable` (has sub-commands: `craft`, `shape`, `audit`, `polish`, `bolder`, `quieter`, `distill`, `delight`, `animate`, `typeset`, `colourise`, `layout`, `clarify`, `harden`…) |
| Implementing a Figma / reference design | `figma-implements-design` + `playwright`/`webapp-testing` for fidelity |
| Full research → strategy → UI → handoff workflows | Owl-Listener's `designer-skills` collection |
| Reusable token systems / theme variants | `theme-factory` |
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
- **Carousels without purpose** — auto-rotating heroes and decorative sliders nobody pages through. It must earn its place (a gallery genuinely browsed); otherwise a static hero, curated grid, or user-controlled scroll.
- **Banned fonts** — `Inter`, Roboto, Arial, Helvetica, Open Sans, Space Grotesk. (SAEED house display is Cormorant Garamond; body is DM Sans. Otherwise reach for Geist, Satoshi, Cabinet Grotesk, Outfit, Clash Display, PP Editorial New.)
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
- **Tokens carry every color** — every value flows through the named token / CSS-variable system (`design-systems-engineer` owns it); a hard-coded per-component hex is a refusal shape. Theming in the brief ⇒ ship variants as token sets (light, dark, high-contrast).
- **Color is never the sole signal** — pair every state change with a second cue: icon, label, weight, or pattern (WCAG 1.4.1; `accessibility-specialist` audits).
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

**Motion holds six laws**; read `references/motion.md` when the surface animates (exact curves and durations there): (1) should it animate at all — 100+×/day actions never animate, frequent ones minimally, occasional ones standard, only rare/first-run moments may delight; (2) every animation names its purpose (spatial consistency, state, explanation, feedback, preventing a jarring change) — "looks cool" is not one; (3) easing: ease-out entering/exiting, ease-in-out morphing, never `ease-in` for UI, strong custom curves over weak built-ins; (4) **UI animation stays < 300ms** (modal/drawer may reach 500ms); (5) physical honesty — nothing appears from nothing (`scale(0.95)` + opacity, never `scale(0)`), buttons respond to press, popovers scale from their trigger; (6) spring physics + staggered reveals for interactive elements.

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
- **Forms hold six laws** (numbered per the source); read `references/forms.md` when the surface contains a form: (1) submit stays disabled until valid **and** what's missing is visibly marked — a mute grayed button is the worse failure; (2) validate inline at field-exit, never only at submit; (3) limited fields show a live character count; (4) pre-fill everything already known; (5) password requirements display as a live checklist ticking as they type; (6) accept forgiving formats (phone with dashes, parentheses, or neither) and normalize once, server-side. Layout: label above input, error text below, sensible gap. Client-side forgiveness never replaces server-side validation — that control is `skills/app-hardening/SKILL.md` rule 5's.

## Trust & perceived responsiveness

UX trust is a design deliverable, held to the same match-and-refuse bar as the visual laws.

- **No dark patterns.** Unsubscribe/cancel is as easy as subscribe, pricing is clear before commitment, no trick copy, confirm-shaming, or pre-checked add-ons. A flow that needs a trick to convert is a design failure, not a growth tactic.
- **Instant acknowledgment on every action.** The UI responds the moment the user acts, even when the backend takes time: acknowledge instantly, run slow work in the background with visible progress — never block the interface on a round-trip. The optimistic-update-with-reconciliation shape this rides on is `skills/performance-discipline/SKILL.md` rule 4 (pointer, not restated).
- **Consistent onboarding controls.** The primary action ("Continue") keeps the same position, style, and label on every screen of a multi-step flow. Spatial consistency is what makes a flow feel safe to walk through.
- **Proportional success states — no action vanishes into the void.** Every action ends in a visible outcome: a major or irreversible action gets a full confirmation moment (a confirmation page; celebration where the register allows it), a minor one gets a subtle checkmark or in-place visual update. The states law above requires a success state to *exist*; this rule sizes it to the action.
- **Failures are designed surfaces.** 404s and backend errors reach the user as composed, human messages ("Something went wrong. Please try again later."), never a raw status page or a dev error. What must never leak inside those messages — stack traces, internals — is `skills/app-hardening/SKILL.md` rule 8's law; this rule owns the designed surface, that one owns the redaction.

## Design handoff — a reference design is law

When a reference design exists (Figma file, mock, or design system), the job is faithful translation, not reinterpretation: build from the system's existing tokens and components, ship **every state the reference implies**, and verify fidelity **in a real browser against the reference**, side-by-side at mobile/tablet/desktop (+RTL where bilingual), grading your own build and fixing mismatches *before* hand-off. An unauthorized deviation is a blocking `design-reviewer` finding; a necessary one (accessibility, an undesigned state) is raised and recorded, never silent. Read `references/handoff.md` when a handoff or reference-design implementation is the task.

## Bilingual / RTL is first-class

- RTL is a real layout, not a mirror hack: **logical properties** (`inline-start`/`inline-end`, `ms-*`/`me-*`), never hard-coded left/right. Test with real Arabic content and long strings.
- Handle mixed-direction runs (Arabic + Latin + numbers) correctly; format dates/numbers/currency by locale (Hijri/Gregorian, numerals).
- Every user-facing surface works, and looks intentional, in both directions.

## The 2026-06 AI-default delta

The June-2026 `frontend-design` revision re-calibrated what "generic" means; read `references/ai-defaults.md` before the plan pass of any surface you originate. Nothing above is repealed; four rules sit on top. (1) **The named blocklist** — three looks are now AI defaults: cream editorial (~`#F4F1EA` + serif + terracotta), near-black + one acid accent, broadsheet hairlines. The brief always wins — but where it leaves an axis free, never spend that freedom on a blocklist look, and the house navy/gold register is **not exempt**: justify it from this brief's subject or pick something else. (2) **Plan, then critique the plan** — build a compact token system (color 4–6 values; type 2+ roles; layout prose + ASCII wireframes; signature), then critique it part by part: **if a similar prompt would land somewhere similar, it is a default, not a decision** — revise before any code, then follow the plan exactly. (3) **The signature slot** — one element this surface is remembered by; every screen keeps a **single visual anchor** (two compete, zero is wallpaper); everything else stays quiet; the mirror rule removes one accessory before hand-off. (4) **Selector specificity cancels silently** — give every spacing property exactly one owning layer.

## Pre-flight checklist — the last filter before hand-off / review

- [ ] Register identified; the AI-slop test passes at both altitudes (domain reflex avoided).
- [ ] No absolute-ban pattern present (fonts, emoji, gradient text, side-stripes, nested cards, hero-metric, meta-labels, em dashes, pure black/white, AI-purple glow, `h-screen`, purposeless carousels, generic content).
- [ ] Color strategy chosen deliberately; OKLCH; tinted neutrals; one palette; accent used with restraint; tokens carry every color; color never the sole signal.
- [ ] Theme justified by a concrete scene sentence.
- [ ] Type scale has real contrast; hero is 2–3 lines; body ≤75ch; Arabic type cared for.
- [ ] Layout breathes (`py-24`+), varies rhythm, breaks center-bias; bento has zero dead cells; cards earn their elevation.
- [ ] Motion passed the "should it animate?" gate; ease-out/custom curves; <300ms; `transform`/`opacity` only.
- [ ] All states present (loading/empty/error/success/offline); realistic content.
- [ ] Trust holds: no dark pattern, every action acknowledged instantly and ended by a proportional success state, onboarding controls stay put, failures reach the user as designed surfaces.
- [ ] Forms hold the six laws: submit gated with visible reasons, inline validation at field-exit, live character counts, known data pre-filled, password rules as a live checklist, forgiving formats normalized server-side.
- [ ] RTL correct and tested; mobile collapses to `w-full px-4`; `min-h-[100dvh]`; blur only on fixed layers.
- [ ] No 2026 blocklist look arrived at by default (cream ~`#F4F1EA` + serif + terracotta, near-black + acid accent, broadsheet hairlines) unless the brief asked for it; the plan passed the convergence self-check and names one signature element; each screen keeps a single anchor.
- [ ] Reference design (if any) matched in-browser side-by-side at mobile/tablet/desktop (+RTL) before hand-off; deviations recorded, never silent.

A user-facing change is **not done** until it passes this checklist and the `design-reviewer` gate.

## Wiring

- `design-reviewer` — owns this canon and is its gate. The 2026-06 delta above is **gate-delegated** to it as a standing review check (cycle 9); a blocklist look the brief did not ask for is a blocking finding.
- Every UI-touching agent already inherits the canon through the auto-activation rule above and inherits the delta with it. The design and build specialists are **deliberately not wired individually** for the delta — class-carrying since cycle 2 already reaches them, and duplicating it would drift.
- `the-boss` — a user-facing item is not DONE until this gate approves.

## Attribution

This canon distills, with gratitude, the enforceable rules of the **impeccable** (Apache-2.0, based on Anthropic's frontend-design skill), **gpt-taste**, **high-end-visual-design**, **design-taste-frontend**, **emil-design-eng** (Emil Kowalski's design-engineering philosophy — [animations.dev](https://animations.dev/)), and **full-output-enforcement** skills. When those skills are installed, prefer invoking them for their full depth; this file guarantees the standard when they are not.

The **2026-06 AI-default delta** section above additionally distills the June-2026 revision of the official **frontend-design** skill (Anthropic) — the named generic-look blocklist, the plan-then-critique convergence self-check, the signature slot, and the selector-specificity warning. When that skill is installed, invoke it for its full depth alongside the others.

The **Space Grotesk and carousel bans, single-anchor rule, token and color-signal laws, and the handoff-fidelity law** (depth in `references/handoff.md`) distill the operator-supplied ten-skill roundup (Chirag T, Medium 2026-05; absorbed 2026-08-24, source: `.saeed/tasks/cycle-13/sources/`): Anthropic's frontend-design + OpenAI's frontend-skill, impeccable's commands, **figma-implements-design**, **playwright/webapp-testing**, Owl-Listener's **designer-skills**, **theme-factory**, Julian Oczkowski's design-process pack, composio, the excalidraw-diagram skill, and **accesslint**.

The **Trust & perceived responsiveness** section distills the UX & Trust portion (credited to Kev + Katia UX) of the operator's 2026-08-06 audit checklist — source preserved in `.saeed/tasks/cycle-10/sources/`. Its skeleton-loader and friendly-error items were already law above; the dark-pattern, instant-acknowledgment, onboarding-consistency, and proportional-success rules are the additions. The **forms laws** (the six-rule block above, depth in `references/forms.md`) distill Katia UX's "Building with Good UX Part 6: Forms", operator-supplied same day — transcript preserved in `.saeed/tasks/cycle-11/sources/`; the old one-line forms rule (label/error/gap) survives inside law 2's layout note.
