# Forms — the six frustration-reduction laws (full treatment)

Load this file whenever the surface you are building, changing, or reviewing
contains a form. The six laws are numbered as the source wrote them (Katia
UX, "Building with Good UX Part 6: Forms"); the one-line versions bind from
the canon body even when this file is never loaded — this file adds the
depth, the edge cases, and the review shapes to refuse.

## 1 — Gate submit on validity, and show why

Keep the submit button disabled until every required field is filled out
correctly — **and make what's missing really obvious**. The disabled button
alone is the *worse* failure: the user stares at a dead control with no idea
why. Mark required fields explicitly; pair the disabled state with a visible,
current list or highlight of what remains. The user is never guessing why
they can't submit.

**Refuse in review:** a disabled submit with no adjacent explanation of what
unblocks it; required fields distinguishable only by trial and error.

## 2 — Validate inline, at field-exit

The moment someone leaves an email field with something that isn't an email,
say so — right there, below the field (the canon's layout law). Never make
the user submit, wait for the round-trip, then scroll back up to discover
what was wrong. Validation feedback belongs to the field, at the moment the
user finishes with it — not to the form, at the moment they thought they
were done.

**Refuse in review:** validation that fires only on submit; an error summary
at the top of the page as the *only* signal (a summary may accompany, never
replace, per-field inline errors).

## 3 — Show a live character count on limited fields

If a field has a length limit, show the remaining count as the user types.
Letting someone write a whole paragraph and then forcing them to delete half
of it is a designed frustration. The count updates live, becomes prominent
as the limit approaches, and never silently truncates.

**Refuse in review:** a `maxlength` that silently stops input or a
server-side limit the UI never surfaces.

## 4 — Pre-fill everything already known

If the user is logged in, their email is already known — never make them
type it again. The same applies to any data the session, profile, or a
previous step already holds: name, locale, country, previously entered
values on a back-navigation. Pre-filled is not read-only: the user can still
edit unless there's a real reason not to.

**Refuse in review:** a form asking for data the app demonstrably already
has in the current session.

## 5 — Password requirements as a live, ticking checklist

Show the password rules **as the user types**, each requirement checking off
the moment it's satisfied. Nobody should submit a password only to learn it
needed a capital letter. The checklist is visible before the first
keystroke, updates per keystroke, and the field's validity (law 1) follows
from the same rules — never a second, hidden rule set that disagrees.

**Refuse in review:** password rules revealed only in a post-submit error;
a strength meter with no named requirements (a vibe is not a spec).

## 6 — Be forgiving with formats; normalize server-side

Phone numbers arrive with dashes, parentheses, spaces, country codes, or
nothing at all — accept all of them and normalize to one canonical format in
the back end. The same forgiveness applies to whitespace around emails,
mixed-case usernames, and Arabic-Indic vs Latin digits (this house is
bilingual; both numeral sets are valid user input). Forgiveness is a
*parsing* posture, not a *security* posture: the normalized value still
passes full server-side validation — `skills/app-hardening/SKILL.md` rule 5
owns that control, and nothing here relaxes it.

**Refuse in review:** a format rejection the code could have parsed
("(050) 123-4567" rejected for its parentheses); client-side normalization
treated as the validation boundary.

## Interplay with the neighbouring laws

- Law 1's disabled-until-valid never conflicts with the trust section's
  **instant acknowledgment**: disabled is a *pre-action* state; once enabled
  and clicked, the click acknowledges instantly as usual.
- Laws 1, 2, and 5 are the same law at three zoom levels: the user always
  knows, in real time, what stands between them and a successful submit.
- Error *placement* beyond the below-field default (summaries, toasts,
  multi-step flows) is expected to arrive as a future absorption from the
  same source series; it lands in this file when it does.
