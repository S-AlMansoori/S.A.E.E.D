# Motion — Emil's framework (full treatment)

Load this file whenever the surface you are building, changing, or reviewing
animates — or you are deciding whether it should. The six laws bind from the
compact block in the canon body even when this file is never loaded; this file
adds the exact curves, durations, and decision detail. (Moved here from the
canon body in cycle 13; nothing below was weakened in the move.)

## 1 — Should it animate at all?

Frequency decides, before taste gets a vote:

- Actions done **100+×/day** (keyboard shortcuts, command palette, list
  keyboard nav) → **no animation, ever**. Repetition turns delight into drag.
- **Frequent** (hover, list navigation) → minimal.
- **Occasional** (modals, toasts) → standard.
- **Rare / first-run** (onboarding, empty-state first fill, success moment)
  → can delight.

## 2 — What's the purpose?

Every animation answers one of: **spatial consistency** (where did this come
from / go), **state indication**, **explanation**, **feedback**, or
**preventing a jarring change**. "Looks cool" on a frequently-seen element is
not a purpose — cut it.

## 3 — Easing

- **Entering / exiting** → `ease-out`.
- **Moving / morphing on-screen** → `ease-in-out`.
- **Hover / color transitions** → `ease`.
- **Constant motion** (marquee, indeterminate progress) → `linear`.
- **Never `ease-in` for UI** — it feels sluggish at exactly the moment the
  user is watching.
- Use strong custom curves, not the weak built-ins:
  `--ease-out: cubic-bezier(0.23, 1, 0.32, 1)`;
  `--ease-drawer: cubic-bezier(0.32, 0.72, 0, 1)`.

## 4 — Duration

Button press **100–160ms** · tooltip **125–200ms** · dropdown **150–250ms** ·
modal/drawer **200–500ms**. **Keep UI animation under 300ms** — only rare,
large transitions (drawer, page) may exceed it, and never past 500ms.

## 5 — Physical honesty

Nothing appears from nothing:

- Enter with `scale(0.95)` + opacity and a gentle fade-up — never `scale(0)`.
- Buttons respond to press: `:active` → `scale(0.97)` or `-translate-y-[1px]`.
- Popovers scale **from their trigger** (transform-origin at the trigger);
  modals stay centered.

## 6 — Spring and stagger

- Prefer spring physics for interactive elements:
  `type: "spring", stiffness ~100, damping ~20` over linear easing.
- Stagger list/grid reveals rather than mounting everything at once.

## Refuse in review

- An animation on a 100×/day action, whatever its quality.
- `ease-in` on any UI transition; default built-in curves on hero moments.
- An element popping from `scale(0)` or appearing with no transition where
  one is expected (jarring change unprevented).
- A modal/drawer past 500ms, or routine UI past 300ms.
- Any motion law traded away against the performance guardrails in the canon
  body (`transform`/`opacity` only, no scroll-listener reveals) — those
  guardrails always win.
