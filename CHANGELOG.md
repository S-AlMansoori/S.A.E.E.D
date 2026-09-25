# Changelog

All notable changes to SAEED are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions follow
semver (patch = fixes, minor = new agents/skills/commands, major = breaking).
The version of record is `version` in `.claude-plugin/plugin.json`.
*(Sections before 1.7.0 are backfilled from commit history and are coarser.)*

## 1.18.0 - 2026-09-25

Operator directive, in session: "run a full /saeed:upgrade and audit on the repo", then "I use
codex now sometimes / a lot". Steps 1–5 of the upgrade ran as role-scoped reviews (model-scout,
self-eval-critic, continuous-improvement-lead audit, appsec/code-review of every executable
file, and a Codex-compatibility research pass). The change set lands as a PR, which is the
supervised-mode approval gate; decisions that change the team's cost or doctrine are parked
below instead of applied.

### Added
- **OpenAI Codex compatibility layer** (`docs/CODEX.md`). `.codex-plugin/plugin.json` (version
  and counts mirrored from the Claude manifest), `.agents/plugins/marketplace.json`, and
  `scripts/gen-codex.sh`, which generates `codex/agents/*.toml` (55 Codex custom agents; model
  tier → reasoning effort, agents with no Write/Edit/Bash → `sandbox_mode = "read-only"`) and
  `codex/skills/` (the 19 canons as symlinks plus the 7 commands as `$saeed-*` skills with
  implicit invocation off), with `--check` drift detection and an idempotent `--install`.
  `AGENTS.md` gives Codex (and any AGENTS.md-aware agent) the contributor rules for this repo.
- **Guardrail hooks understand Codex edits.** Codex routes every file edit through
  `apply_patch`, with no `file_path`; the three edit guards fail open on that shape. A shared
  stdlib module, `hooks/lib/hookio.py`, parses the patch envelope into per-file records and is
  the one home for shell write-target extraction (quote-aware, `cd`-tracking).
- **Validator Checks 15–17.** 15: every README/CHEATSHEET roster row's Model column matches
  frontmatter (the class that let `team-orchestrator` read `opus` for three releases after its
  move to Fable). 16: handoff reciprocity — every agent is named in another agent's Handoffs.
  17: the generated Codex layer is in sync. Check 13 is now two-way (every agent appears in
  the capability map), Check 1 covers the Codex docs' agent count, and the PASS summary says
  which `.saeed/` clauses were skipped instead of claiming them.
- **43 new Check 8 fixtures (29 → 72 hook assertions):** 31 bypasses reproduced against the
  previous hooks (exit 0 then, exit 2 now) and 12 benign cases pinning the false-positive
  floor. Verified by swapping the old hooks back in: the validator goes red on exactly the 31.

### Fixed
- **`guard-git-bypass.sh`** now tokenizes with `shlex` the way the shell will. Previously
  bypassed: `--no-verify` between apostrophe-bearing messages (the single-quote regex ran
  first), shell-quoted flags (`--"no-verify"`, `-c "core.hooksPath=…"`, `git config
  "core.hooksPath"`), git's accepted abbreviation `--no-verif`, `-n` inside clusters like `-en`,
  `GIT_CONFIG_KEY_n` / `GIT_CONFIG_PARAMETERS` / `--config-env`, and `HUSKY=0`.
- **`guard-tdd-mode.sh`**: sentinel tamper via `tee`, `sed -i`, `truncate`, `mv`, a doubled
  slash, a `./` segment, a glob (`TD?`), and `cd .saeed && rm TDD` all passed under `enforce`.
  Paths are now normalized and compared case-insensitively (APFS). The sentinel is found by
  walking up from the payload's `cwd`, so a subdirectory session is covered, and git runs in the
  target's repo. `cat > src/x.py <<EOF` is a bypass write like `echo >>`. `git status
  --porcelain -z` stops a spaced test path being misread as "no test".
- **`guard-attribution-canon.sh`**: any Bash command that merely *mentioned* an exempt filename
  was exempt, and `NOTCHANGELOG.md` matched the `CHANGELOG.md` suffix; tatweel and zero-width
  characters hid a banned form. The exemption now requires every write target to be exempt; text
  is NFKC-normalized with invisible characters stripped.
- **`guard-config-protection.sh`** is registered on Bash as well (`sed -i`/redirect/`rm` on an
  existing lint config), compares names case-insensitively, and protects `.eslintignore`,
  `.prettierignore`, `eslint.config.{mts,cts}` and `prettier.config.{ts,mts,cts}`.
- Every guard prints a one-line stderr warning when python3 is missing instead of failing open
  silently. `saeed-loop.sh` rejects non-numeric `max_cycles`/`sleep_seconds`.
- **Model-tier drift:** README and CHEATSHEET listed `team-orchestrator` as `opus`; the README
  tier sentence omitted Fable; `docs/SUCCESSION.md` still said the fable tier had no alias.
  `model-scout` now owns the doc surfaces that restate a tier.
- **Orphaned agents:** `lottie-engineer`, `pwa-offline-engineer`, `python-engineer` and
  `typescript-specialist` had no inbound handoff; reciprocal handoffs added from the agents
  they hand to. `python-engineer` and `typescript-specialist` gain capability-map rows, and the
  map gains rows for handover, context discipline, housekeeping and the Codex layer.
- Doc accuracy: the opt-in TDD guard is documented in SECURITY/README, the `.saeed/TDD` sentinel
  in the `.saeed/` tables (EN + AR); `help.md` names the steward; `continuous-improvement-lead`'s
  audit dimensions match `/saeed:improve`; CONTRIBUTING and `roster-maintainer` list every
  surface a roster change touches; "opus/sonnet tallies" → fable/opus/sonnet. The NABAD credit
  footer is added to SECURITY, CAPABILITY-MAP and SUCCESSION.

### Changed
- CI runs the gate on `ubuntu-latest` and `macos-latest` (bash 3.2, BSD userland,
  case-insensitive filesystem), with a timeout and a concurrency group.

### Added (operator decision, same release)
- **`skills/app-hardening/SKILL.md` gains AI1–AI7, the gate for AI features the product ships**,
  distilled from the OWASP Top 10 for LLM Applications 2025 (LLM01, 05, 06, 07, 08, 10):
  untrusted content is data, authorization and retrieval filtering stay outside the model,
  least agency with confirmation on high-impact actions, model output validated and
  context-encoded (off-allowlist links and images stripped as exfiltration channels), no
  secrets in the system prompt, bounded consumption, and a shipped direct + indirect injection
  eval. Plus the product-side twin of agentic-security's trifecta rule. The "seventeen-point"
  gate is unchanged. The A-items sit beside it, the same way the legal items do. Consult lines
  were added to `llm-engineer`, `rag-architect` and `vector-search-engineer`, and the
  capability-map row that named the gap now names the rule. Light eval per
  `skills/canon-craft/SKILL.md` (independent coherence pass + one cold trigger smoke on an
  `llm-engineer` task); evidence summarized in the PR.

### Operator decisions recorded
- **MS-1 re-tier: declined.** Operator: "opus currently beats fable". No agent moves to Fable.
  The standing re-tier question is closed until a model release changes that comparison.
- **Roster redundancy review: delegated to the team, decided "keep and wire".**
  `python-engineer`, `typescript-specialist` and `prompt-engineer` stay. The first two now have
  inbound handoffs and capability-map rows. Revisit trigger: usage evidence (the retro shows one
  of them never routed to across three cycles), not scope overlap on paper.

## 1.17.0 - 2026-09-11

Operator directive, in session: "audit and improve" the new SecureMax repository once its
first implementation landed, then "absorb SecureMax into S.A.E.E.D". Supervised-mode approval
was therefore satisfied at the source; nothing parked.

### Added
- **`skills/securemax/SKILL.md`** — the absorbed SecureMax canon: the boundary between a
  public synthetic twin and an air-gapped real installation. Nine rules numbered as the
  operator's standard writes them (S01–S09): demo data synthetic by construction with
  *renaming is not anonymization* stated as a refusal; the five-category state map
  (`shared` / `synthetic-only` / `site-local` / `secret` / `unknown`, unknown excluded until
  reviewed); the twin-specific entrypoints app-hardening does not name (alternate hostnames,
  preview deployments, direct-origin behind a proxy, public media under a "protected" page);
  offline independence with the air gap verified physically; signed and bounded packages
  whose in-package key is never a trust anchor and whose manifest never selects a command;
  separate enrollment/rotation/revocation with a sequence high-water that rollback retains;
  immutable staged activation with a receipts ledger; tool permissions enforced independently
  of the model; and the acceptance record. Plus the adapter rule (`static-files-v1` is the
  only implemented adapter; naming one does not implement it) and the identity-token
  section. Consult-line-wired into twelve agents; `the-boss` gains a SecureMax DoD line;
  `/saeed:hire` records the applicability predicate in Phase 1 and consumes the acceptance
  record in Phase 3; `/saeed:improve` step 1 audits against it where the predicate holds;
  three capability-map rows.
- One home per rule held on purpose: route-level authorization stays in `app-hardening`,
  restore mechanics in `production-readiness`, the prompt-defense baseline in
  `agentic-security` — this canon points, never restates. The SecureMax engine is invoked
  from its repository, not vendored, so its fixes version there.

### Changed
- **SecureMax itself** was reviewed first (that repository's `docs/REVIEW-2026-09-11.md`):
  eleven findings, all code findings fixed there before absorption — the standard's S07
  "activation MUST be recorded" was not met by the engine (a `receipts.jsonl` ledger now is),
  the shared/local partition was path-only (a private identity profile under any file name
  is now refused by content), and the export attestation was browser-only (now recorded
  server-side). Absorbing a canon whose reference implementation contradicted it would have
  absorbed the contradiction.
- Light eval per `skills/canon-craft/SKILL.md`: adversarial coherence pass and one trigger
  smoke, evidence in `.saeed/tasks/cycle-13/`.

## 1.16.2 - 2026-09-03

Steward-found defect SB-2, fixed on operator instruction ("fix SB-2 so the ledgers stay in
parity"): three releases in a row — v1.15.0, v1.16.0, v1.16.1 — shipped with every gate
green while the narrative ledgers in `.saeed/` stayed a release behind. The v1.16.1
release was only noticed as stale when the 2026-09-03 steward pass pulled it and Check 12
went red on `state.json`; `queue.md` and `retro.md` had no gate at all.

### Fixed
- **Check 12 now covers the narrative ledgers.** `scripts/validate-fleet.sh` asserts that
  the `plugin.json` version of record appears as a standalone token in both
  `.saeed/queue.md` and `.saeed/retro.md` (when they exist — `.saeed/` is gitignored, so a
  fresh clone or CI gets a note, never a false red). Root cause was the same
  presence-vs-content blind spot as SB-1: `state.json` was in the parity set, the two files
  that carry the *why* of a release were not, and `git status` cannot see a stale gitignored
  ledger. Red/green demonstrated on this very release: the check went red the moment
  `plugin.json` said 1.16.2 and the ledgers did not, and green once they recorded it.
- Header comment and summary line of the validator describe the new clause; the count of
  hard checks is unchanged (14), since this extends Check 12 rather than adding a sibling.

## 1.16.1 - 2026-08-25

Field defect, reported by the operator: some generated surfaces printed the company's
Arabic name as `ناباد` instead of `نبض`. `نبض` is an ordinary Arabic word — *nabḍ*,
"pulse" — and it is the company's actual name; `NABAD` is its romanization. `ناباد` is
that romanization spelled back out in Arabic letters: not a typo, a different name, and
a misspelling of the client's own name on the surfaces meant to credit them.

### Fixed
- **Root cause was structural, not careless.** The Arabic string existed in exactly one
  file (`skills/attribution/SKILL.md`); every other surface that ordered the credit said
  only "carry the NABAD credit, bilingual". An agent writing an Arabic surface without
  that canon loaded therefore had no string to copy — so it derived one, and the only
  derivation available from the Latin name is a transliteration. Nothing forbade the
  derivation and nothing detected the result, so it shipped. Fixing the strings alone
  would have left every one of those conditions in place.
- **The derivation is now forbidden by name.** `skills/attribution/SKILL.md` gains
  *"The Arabic name is a word, never a transliteration"*: the romanization direction is
  stated explicitly, each wrong form is tabled with why it is wrong (transliteration
  attempts; `نابض` — a real word, but not the name; `النبض`/`نبضة` — right root, wrong
  form), and the canonical-strings section now says copy, never retype or re-derive.
- **The string travels to the point of use.** Both credit strings are now carried
  verbatim in `technical-writer`, `frontend-engineer`, `ui-visual-designer`, `the-boss`,
  `/saeed:hire`, and `/saeed:improve` — the agents that actually write credit surfaces no
  longer have to reach one hop away for the name they are about to print.
- **The two agents who own the failure mode get the explicit carve-out.**
  `i18n-localization-engineer`: brand and proper nouns are fixed assets, not translatable
  copy. `nlp-bilingual-specialist` — the agent that owns transliteration — transliterates
  only names that have no native form, and never normalizes an authoritative spelling away.

### Added
- `hooks/guard-attribution-canon.sh` — PreToolUse guard on `Write|Edit|MultiEdit` and
  `Bash`. Blocks a write carrying a wrong form, on the tool-call and shell channels both,
  and answers with the canonical string so the fix is a copy. Two properties it is built
  around: reads are never blocked (`grep ناباد -r .` is how an operator diagnoses this),
  and matching is Arabic-word-boundary anchored, never bare substring — `نباد` is a
  substring of the everyday verbs `نبادل` and `نبادر`, and blocking ordinary Arabic copy
  would be a worse defect than the one being fixed. Real words that are merely the wrong
  *name* (`نابض`) are flagged only in company-name position, so `نبض الوصاية` in SAEED's
  own docs stays legal. 11 behavioural cases join the check-8 hook contract.
- **Validator check 14 — attribution string canon.** Three rules: the canonical EN + AR
  strings are intact in the canon file; every Arabic credit line in the repo (anything
  reading `<name> لحلول الكمبيوتر`) names `نبض`; and the known-wrong forms appear nowhere
  except as backtick-quoted mentions in files that reference the canon. Rule two is the
  one that matters — it is written against the *shape* of a credit line rather than a
  list of misspellings, so it catches wrong forms nobody thought to ban (verified: an
  invented `نابادو` fails the build). Use-vs-mention is honoured so doctrine can still
  name what it forbids; the four files that *are* the ban list are the registry and are
  skipped wholesale.

### Changed
- `SECURITY.md`, `skills/agentic-security/SKILL.md`, `README.md`, `CONTRIBUTING.md`, and
  `docs/CHEATSHEET.md` (EN + AR) restate the guardrail set as three hooks, not two — the
  stale-bookkeeping class this repo polices applies to its own hook roster too.

## 1.16.0 - 2026-08-06

Same-day operator tip absorbed, from the standing stream of field advice the operator
feeds SAEED ("add it to the many tips i give it"): five backend audit prompts —
over-fetching, N+1, unreleased database connections, orphaned storage blobs, and hidden
background jobs holding pool connections — with the instruction that SAEED should just
**do this whenever hired**, rather than wait to be asked each time.

### Changed
- `skills/performance-discipline/SKILL.md` gains **the inherited-backend audit (A1-A5)**,
  a section deliberately separate from the canon's numbered five rules. Those five are
  construction rules — they refuse a pattern as it is being written and are structurally
  blind to a backend that already exists. A1-A5 are the sweep half, run without being
  asked on every hire and every improvement pass, each with a default remedy and each
  N/A-capable in writing only. Source ordering preserved item-for-item.
- **A2 (N+1) enters as a route, not a new home.** `code-reviewer`'s check class and
  `query-optimization-engineer`'s ownership already covered N+1; what neither ever does
  is sweep code that landed before SAEED arrived. That gap — not the rule — is the delta.
- Keeping the existing "five rules" count accurate across all four external references
  was a design constraint, not an accident: the stale-count defect class (cycles 1, 3, 9,
  and the ten-point de-numbering in cycle 10) is now avoided by construction.
- Wired: `/saeed:hire` Phase 3 (explicitly on **every** hire, not only takeovers) and
  `/saeed:improve` step 1; audit owners named in the canon's Wiring block and carried into
  `frontend-performance-engineer` (steward), `query-optimization-engineer` (A1-A3, A5
  diagnosis), `backend-engineer` (fixes, plus A3/A4 closed at the source),
  `sre-observability-engineer` (the live-pool and per-worker evidence A3/A5 verify
  against — neither is readable from code), `cloud-infra-engineer` (A4 bucket lifecycle),
  and `code-reviewer` (the two items that genuinely are diff shapes, A1 and A3).
- `skills/supabase-craft/SKILL.md` Storage and Cron & Queues get one-line pointers to
  A4 and A5 — pointers only, no restatement, one home per rule.

## 1.15.0 - 2026-08-06

Same-day operator hire directive: "Add a Lottie expert to the team that will be able to
edit and manipulate lottie to the users' will" — with the routing rule given in full:
"Anything lottie related to it, goes to that agent." The first roster growth since
macos-engineer (v1.4.x line), and the first hire where the operator supplied the
staffing decision directly rather than through an hr-talent-lead gap report.

### Added
- `agents/lottie-engineer.md` (sonnet) — the **mandatory owner of ALL Lottie work**.
  Per the directive's second clause the description is MUST-BE-USED and deliberately
  keyword-saturated so any Lottie-touching task routes there: Lottie JSON,
  .lottie/dotLottie, Bodymovin/After Effects exports, lottie-web/lottie-react,
  lottie-react-native, lottie-ios, lottie-android, dotLottie players (ThorVG),
  rlottie, LottieFiles. Owns hands-on JSON manipulation (layers, shapes, transforms,
  keyframes, bezier easing, markers, named segments), token-mapped rethemes, text and
  image asset swaps, retiming/trimming/splitting/reversing/looping, file-size
  optimization and JSON↔.lottie conversion, player integration and playback control
  on every house platform, RTL mirroring rulings for Arabic surfaces, reduced-motion
  and poster-frame fallbacks, and renderer/performance discipline (svg vs canvas,
  lazy loading, off-main-thread playback). Born carrying the Elite Design Mandate
  and the screenshot-or-block + engine-honesty certification rules — an animation is
  not done until it is seen playing.
- The agent carries the house asset-library doctrine, supplied by the operator in the
  same session: S.A.E.E.D. Lottie assets live in the private repo
  `github.com/S-AlMansoori/nabad-motion-library` (**internal Nabad use only**) — the
  library is checked before authoring or importing from anywhere else, finished
  optimized animations are contributed back, and a guardrail forbids the assets (or
  the library URL) from appearing in public repos, external deliverables, or
  user-facing output.

### Changed
- Roster 54 → 55 (1 fable / 23 opus / 31 sonnet) across every counting surface:
  README (copy, badges, roster heading + table), CHEATSHEET (EN + AR), WHAT-IS
  (EN + AR, division prose names the new engineer), what-is-saeed.html (meta, hero,
  chip, org heading, donut numeral + arcs, model-mix legend, Arabic hero), both
  manifests (+ `lottie`/`animation`/`motion` keywords), `.saeed/models.md`,
  `.saeed/state.json`.
- `docs/CAPABILITY-MAP.md` gains the Lottie row under Product Surfaces (owner
  `lottie-engineer`; doctrine: the design canon's motion laws; gate:
  `design-reviewer`).

### Fixed
- what-is-saeed.html's "Specialists per division" bars still showed Frontend & Mobile
  at 7 — stale since the macos-engineer hire, so the division sum read 53 under a 54
  donut. Corrected to 9 (8 members + lottie-engineer); the bars sum to the roster
  again. The divbars array is a surface Check 1 does not assert — noted in the retro
  as a validator candidate.

## 1.14.0 - 2026-08-06

Same-day addendum to cycle 11: the operator supplied Katia UX's "Building with Good UX
Part 6: Forms" transcript ("here are some more tips to absorb").

### Added
- `skills/design-excellence` gains the **six forms laws**, numbered as the source wrote
  them: (1) submit gated on validity **with what's missing visibly marked** — a mute
  grayed button is the worse failure; (2) inline validation at field-exit, never only at
  submit; (3) live character counts on limited fields; (4) pre-fill everything already
  known; (5) password requirements as a live checklist ticking as the user types;
  (6) forgiving input formats (phone with dashes/parentheses/neither; Arabic-Indic and
  Latin digits both valid) normalized once, server-side. Client-side forgiveness never
  replaces server-side validation — that control stays with `app-hardening` rule 5.
- **First exercised `references/` split** (canon-craft F5 was untested until now):
  the canon body was ~1.2k chars under its F4 budget, so the six laws bind as one
  compact block in the body and the full treatment — edge cases, refuse-in-review
  shapes, interplay with the trust laws — lives in
  `skills/design-excellence/references/forms.md`, loaded when the surface contains a
  form. The source's teased part 7 (error placement) has a named landing place there.

### Changed
- The old one-line forms rule (label above input, error below, sensible gap) survives
  as the block's layout note. Pre-ship checklist gains a forms line; CHEATSHEET (EN+AR)
  names the forms laws. Source transcript preserved in `.saeed/tasks/cycle-11/sources/`.

## 1.13.0 - 2026-08-06

Cycle 11 — the operator's capability mandate ("I want SAEED to do all this — feel free
to add stuff"): nineteen capabilities across Security & Compliance, Testing & Quality,
Architecture & Infrastructure, and DevOps & Deployment, audited against the fleet
before a single edit. Thirteen were already covered; the gaps became the change set.

### Added
- `skills/production-readiness` — the **ops pre-ship gate**, the entropy-twin of
  `app-hardening`'s attacker gate. Seven match-and-refuse rules, each tracing to a
  zero-hit grep from the coverage audit: (1) backups proven by an **actual restore**
  with named RPO/RTO (a backup never restored is a hope); (2) a product
  disaster-recovery runbook (distinct from the team's own in `self-governance`);
  (3) dev/**staging**/prod tiers with per-environment secret sets ("staging" appeared
  nowhere in doctrine before this); (4) load-verified non-functional targets (k6-style
  generated load, percentile assertions — targets were set at intake and never
  verified); (5) deliberate caching with TTL + invalidation and a never-cache rule for
  authz-scoped data; (6) encryption at rest verified on every store *including
  backups*, keys under named custody; (7) a named compliance surface — GDPR, UAE PDPL,
  SOC 2, HIPAA/PCI-DSS awareness (no standard was named anywhere repo-wide before).
  Steward + gate: `sre-observability-engineer`; nine applying agents wired.
- `docs/CAPABILITY-MAP.md` — the persistent capability→owner→gate map across all nine
  divisions. Exists because the audit proved an unowned capability was structurally
  invisible: roster tables inventory agents, so nothing failed while backups had no
  owner.
- **Validator Check 13** — capability-map ownership: the map must exist and every
  agent owner named in it must resolve to `agents/*.md`. Red/green demonstrated
  (RED on a planted `chaos-goblin-engineer`).

### Changed
- Eleven agents extended surgically: `compliance-privacy-engineer` now names GDPR /
  UAE PDPL / SOC 2 (HIPAA/PCI-DSS awareness) and owns the named-regime compliance
  map; `security-architect` gains at-rest encryption + key-custody doctrine;
  `sre-observability-engineer` stewards the new canon and its gate (backups/DR/RPO/
  RTO); `qa-automation-engineer` + `test-architect` gain load/stress testing;
  `backend-engineer` + `edge-serverless-engineer` gain the cache-with-invalidation
  contract; `devops-platform-engineer` gains the three-tier environment default;
  `cloud-infra-engineer` gains backup-fabric IaC + multi-provider breadth
  (AWS/GCP/Azure/Terraform when the repo lives there); `database-architect` gains
  PITR/restore mechanics.

### Fixed
- `appsec-engineer` still said "any of the **ten** points" for the seventeen-point
  gate it stewards — de-numbered to "any of its points" per the one-home count rule.
- Both manifests still advertised a "10-point" app-hardening gate — same de-numbering.

## 1.12.0 - 2026-08-06

Same-day addendum to cycle 10: the operator extended the audit checklist with a Legal
section (credited to Ryan Naghibzadeh, "How to NOT Get Sued Building Your First App").

### Changed
- `skills/app-hardening` — new **"Legal pre-ship items"** section, L1–L2, deliberately
  numbered apart from the security gate's 1–17: **L1** every shipped app carries a
  reachable EULA (generators like TermsFeed/Termly as baseline, counsel for anything
  bespoke); **L2** any app accepting user-generated content publishes a DMCA policy with
  a working claims process — conditional on the observable UGC predicate, N/A with reason
  otherwise. Both owned by `compliance-privacy-engineer` in its advisory-not-legal-advice
  register; its scope and description extended to carry the ownership.
- Doc surfaces follow (README, CHEATSHEET EN+AR, WHAT-IS EN+AR). No legal doctrine
  existed anywhere before this (EULA/DMCA: zero grep hits repo-wide).

## 1.11.0 - 2026-08-06

Cycle 10 — absorb the operator's four-part audit checklist (UX & Trust [Kev + Katia UX],
Security [Michael Ly + Casco], Performance [Hayden Smith], AI Automation Readiness
[Ahmed Alassafi]), folded into a `/saeed:upgrade` run the operator invoked mid-cycle.
Coverage audit first, per the house idiom: the Performance section was already absorbed
rule-for-rule (`skills/performance-discipline`, same source), and the Security section's
first ten items are the existing gate in the operator's own order — so the cycle extends
three canons rather than adding one. Source verbatim in `.saeed/tasks/cycle-10/sources/`.

### Changed
- `skills/app-hardening` — the pre-ship gate grows from ten to **seventeen** points, numbered
  as the operator wrote them: IDOR/object-level authorization (11), real logout (12), file
  upload safety (13), payment-webhook signature verification (14), deny-by-default access
  control beyond tables (15), centralized access checks (16), record ownership at the
  data-model level (17). The eight external references to the gate (5 agents, 3 commands)
  and the doc surfaces (README, CHEATSHEET EN+AR, WHAT-IS EN+AR) are **de-numbered** to
  "pre-ship gate" — the stale-count defect class (cycles 1, 3, 9) applied preventively, so
  the count now lives in exactly one home.
- `skills/design-excellence` — new **"Trust & perceived responsiveness"** law set: no dark
  patterns, instant acknowledgment with background processing, consistent onboarding
  controls, proportional success states ("no action vanishes into the void"), failures as
  designed surfaces. Skeleton loaders and friendly errors were already law.
- `skills/spec-quality` — new **"The AI-automation readiness map"**: every workflow task
  classified human-led / human-assisted / fully autonomous, plus one named knowledge-base
  source of truth for all AI features; binds at the requirements layer, N/A-capable.

### Evidence
- Light eval per `skills/canon-craft`: a **live fresh-agent trigger smoke** (exceeds
  cycle-9's traced-smoke precedent) — a clean-context reviewer found all three planted
  defects citing the new gate items 11/12/14 and returned BLOCK. Coherence ran inline by
  the coordinator after two independent-critic attempts died to the session usage limit;
  the independent re-run is queued debt. Evidence: `.saeed/tasks/cycle-10/eval-evidence.md`.
- Upgrade steps 2–5 concluded inline under the usage limit: NO-HIRE (no exercised gap,
  cycle-5 precedent), no optimizer/roster changes, MS-1 (fable re-tier) surfaced to the
  operator for decision.

## 1.10.0 - 2026-07-25

The absorption cycle: seven operator-named external skill sources (two Supabase skills, the
`/security-review` change-level review, `/engineering:code-review`, the `securitymaxxing`
10-point checklist, Hayden Smith's 5 slow-app reasons, mikesol's `repository-housekeeping`) plus a
verified ten-source research shortlist (Anthropic's `skill-creator` + authoring best practices +
the Agent Skills open standard, Obra's `superpowers`, nizos's `tdd-guard`/Probity, GitHub Spec Kit,
Anthropic's `mcp-builder`, EveryInc's compound-engineering plugin, the 2026-06 frontend-design
revision, `webapp-testing`, and `doc-coauthoring`) — see
`.saeed/tasks/cycle-9/skill-research.md` — distilled into eight new house canons and seven
additive extensions to existing ones, per the house absorption idiom (`skills/design-excellence`,
`skills/agentic-security`).

### Added
- **`skills/supabase-craft`** — schema/migrations, Auth/JWT/RLS and `@supabase/ssr` sessions, Edge
  Functions, Realtime, Storage, Vectors, Cron/Queues, client patterns with service-role isolation,
  CLI/MCP, security advisors, extensions, and Postgres query/schema/config performance.
- **`skills/app-hardening`** — the 10-point pre-ship gate (rate limiting, server-side secrets, RLS
  everywhere, `.env` hygiene, input validation, explicit permissions, auth on every protected
  route, generic errors, locked-down admin surfaces, attack-visible logging), disjoint from
  `skills/agentic-security` (product vs team).
- **`skills/performance-discipline`** — never ship uncompressed responses, never write rows one at
  a time, name the slowest dependency before optimizing, update UI optimistically with
  reconciliation, serve static frontends statically.
- **`skills/repo-housekeeping`** — git hygiene and untracked-file triage (commit-over-delete with
  a secrets exception), two-copies/upstream sync discipline (the operator's "check drift"
  instinct, now doctrine), recent-session knowledge distillation, organizational and
  orientation-file audits, and close-out reporting. Tends the *workspace*; the improvement loop
  tends the *product*. Its entrypoint is the steward branch of `/saeed:improve` — no new command
  and no script change — and its gate is `the-boss`'s Workspace-clean DoD. The canon and its
  wiring ship here; the first executed housekeeping pass is deliberately its own first outing.
- **`skills/engineering-method`** — the TDD Iron Law with its rationalization counters, four-phase
  systematic debugging, the brainstorm HARD-GATE before implementation, the zero-context plan law,
  subagent-controller mechanics, TDD adjudication rules (Probity), and the task-size (S/M/L)
  applicability ladder — defined exactly once, here, and referenced by every other canon and gate
  that scopes itself by task size. The ladder classifies *code changes*; work that ships no code
  answers to its own gates. Ships with a scoped, **opt-in** `hooks/guard-tdd-mode.sh` gated on a
  `.saeed/TDD` sentinel (`off`/`advisory`/`enforce`) as its mechanical floor — a repo with no
  sentinel is a no-op, and the hook blocks the shell bypass channels (`echo`/`printf`/`sed`/
  `awk`/`perl` redirects) as well as sentinel tampering.
- **`skills/canon-craft`** — the eval-driven authoring loop, description-trigger optimization,
  spec conformance (metadata/body/line budgets, one-level references), degrees-of-freedom
  calibration, and grounding-in-real-execution-traces discipline that now governs `/saeed:upgrade`
  and every canon authored from this cycle forward. The eight canons below were held to its
  mechanical floor (F1–F10) plus a light eval — a coherence pass and one trigger smoke each —
  with that scoping decision and its cost written into the canon itself. Agent files, commands,
  and hooks are deliberately out of its scope, and a retro-audit of the nine pre-existing canons
  is queued to the next cycle, not done here.
- **`skills/spec-quality`** — the ten-category ambiguity taxonomy, the bounded five-question
  clarification budget with informed-default Assumptions, answer integration, checklists as unit
  tests for requirements, and the read-only pre-implementation analysis gate with its
  requirements-to-tasks coverage table. Sits upstream of `skills/orchestration-protocol`.
- **`skills/mcp-craft`** — quality measured by LLM task success (a shipped 10-question agentic
  eval), API-coverage-over-workflow tool design, `{service}_{action}_{resource}` naming,
  pagination/truncation contracts, dual JSON/Markdown responses, and MCP-specific security
  hardening (token-audience validation, DNS-rebinding protection, Origin validation, loopback
  binding).
- **`/saeed:verify` security depth** — auto-escalates (or is invoked explicitly as
  `/saeed:verify security`) on diffs touching auth, input handling, secrets, the network boundary,
  new dependencies, or admin/debug surfaces: a severity-ranked findings report over the diff and
  its blast radius, ending in an explicit pass/block verdict.
- **`scripts/validate-fleet.sh` Checks 10 and 11** — two new hard checks, added mid-cycle beyond
  the planned scope because this cycle produced two live proofs the existing checks could not see.
  **Check 10 (cross-reference resolution)** resolves every `skills/<name>/SKILL.md` reference
  found under `agents/`, `commands/`, `skills/`, `hooks/`, `docs/`, or `README.md` against the
  filesystem, and asserts `.saeed/state.json`'s `skills` array against the real `skills/*/`
  directories in both directions. It closes a hole Checks 5 and 9 structurally cannot see: this
  cycle wired 28 references to a canon that had never been written, across 24 files, and the
  validator stayed green the whole time — Check 9 only enumerates directories that exist, and
  Check 5 only resolves backticked tokens inside a `## Handoffs` section.
  **Check 11 (canon reference form)** fails any bare backticked `` `skills/<name>` `` without
  `/SKILL.md`, and any line-anchored `SKILL.md:<digits>` cross-reference, on a doctrine surface
  (`skills/`, `agents/`, `commands/`, `hooks/`). Check 10 matches only well-formed references, so
  a typo'd canon name or a line anchor pointing at the wrong rule shipped green — which is exactly
  where this cycle's last two blocking defects hid. The fenced-code exclusion is scoped to
  `skills/canon-craft/SKILL.md` alone, the one canon that must be able to illustrate the form it
  forbids. Exit status is now "all hard checks (1–5, 7–11) passed".

### Changed (additive extensions — prior doctrine unchanged)
- **`skills/continuous-improvement`** — the codify step (schema'd learning docs filed to
  `.saeed/solutions/`), 5-dimension overlap scoring + staleness refresh, grounding validation, the
  `.saeed/CONCEPTS.md` vocabulary rule, the feed-forward mandate, and the one-pipeline knowledge
  routing tree (instincts vs the solutions library vs housekeeping distillation).
- **`skills/orchestration-protocol`** — Superpowers' worktree/parallel-dispatch/executing-plans
  deltas.
- **`skills/verification-protocol`** — E2E browser-evidence verification (server-lifecycle
  harness, headless Chromium, pre-navigation console-log capture, modernized web-first
  assertions), the bilingual doc cold-reader gate (AR and EN gated separately), and one pointer
  line escalating gate 5 to the new security depth.
- **`skills/self-governance`** — a constitution-governance subsection (a semver-versioned
  constitution artifact; violations auto-CRITICAL).
- **`skills/design-excellence`** — the 2026-06 delta: the named generic-AI-look blocklist (with
  hexes), the plan-then-critique convergence self-check, the one-signature-element token slot, and
  the CSS selector-specificity warning — including the corrective note that SAEED's own
  navy/gold-minimalist register must pass the same reflex check.
- **`skills/agentic-security`** — one line naming the TDD-mode guardrail hook in "Mechanical
  rails".
- **`skills/context-discipline`** — one line: the black-box test-infra rule.
- **`agents/code-reviewer.md`** — absorbs `/engineering:code-review`'s four check classes (N+1,
  injection, missing edge cases, error-handling gaps) as standing review lenses; adds
  `skills/supabase-craft/SKILL.md`, `skills/app-hardening/SKILL.md`, and
  `skills/performance-discipline/SKILL.md` as review lenses; carries
  `skills/engineering-method/SKILL.md`'s validator-conduct rules (re-derive judgment fresh, name
  the rationalization, treat an explicit operator override as authoritative) and an S/M/L
  tier sanity-check on every diff; and gains a reciprocal `query-optimization-engineer` handoff —
  N+1 is flag-and-route, never a transfer of ownership.
- **`/saeed:hire`, `/saeed:improve`, `/saeed:upgrade`** — the lifecycle entrypoints reference the
  new canons where sibling canons already appear: spec-quality and performance NFR targets at the
  spec phase, engineering-method's S/M/L tier and the Supabase/hardening/review gates at the build
  phase, app-hardening and performance-discipline in `/saeed:improve`'s audit dimensions plus the
  codify step and the housekeeping pass on its steward branch, and canon-craft in `/saeed:upgrade`
  wherever skills are authored.
- **Docs and manifests, EN + AR** — README absorbed-canon bullets, `docs/CHEATSHEET.md` skills
  lists (English and the Arabic mirror), `docs/WHAT-IS-SAEED.md` prose (English and Arabic), and
  the `plugin.json` / `marketplace.json` descriptions and keywords all name the new canons. No
  skills count is stated anywhere, in either script — counts were removed in 1.9.0 precisely
  because they drift. `docs/what-is-saeed.html` is byte-identical: no command was added.
- Class-wide wiring per the propagation invariant (SU-17): every new canon is applied by a named
  agent class or delegated to a named gate, and every deliberate exclusion is written down — see
  each canon's Wiring section, which is the shipped record of truth.

### Credits
Distilled from (never vendored — "never let a missing plugin lower the bar"): the operator-named
Supabase, `/security-review`, `/engineering:code-review`, `securitymaxxing`, and
`repository-housekeeping` (mikesol/cc-disco) skills; Anthropic's `skill-creator` and its authoring
best practices; the Agent Skills open standard (agentskills.io); Obra's `superpowers`; nizos's
`tdd-guard`/Probity; GitHub Spec Kit; Anthropic's `mcp-builder`; EveryInc's compound-engineering
plugin; the 2026-06 frontend-design revision; and `webapp-testing` / `doc-coauthoring` — per the
research decision document `.saeed/tasks/cycle-9/skill-research.md`.

## 1.9.1 - 2026-07-15

### Changed
- **Attribution simplified to a single credit line** (operator instruction):
  every visible credit surface now shows exactly
  `Developed by NABAD Computer Solutions L.L.C.` (Arabic mirror
  `تطوير نبض لحلول الكمبيوتر ذ.م.م.` on bilingual surfaces; commit trailer
  `Developed-By: NABAD Computer Solutions L.L.C.`). The full / short /
  facilitated variants are retired; existing older variants get updated to
  the canonical line when touched. The machine-readable
  `facilitated_by` ledger key is unchanged for compatibility. Updated
  `skills/attribution`, `/saeed:hire`'s state-file header, and the
  agent wiring (`technical-writer`, `frontend-engineer`,
  `ui-visual-designer`).

## 1.9.0 - 2026-07-15

### Changed
- **`/saeed:hire` rewritten as the A-to-Z operational lifecycle runbook** —
  five gated phases, each with named owners and an explicit exit line:
  **Phase 0 Intake** (project-root fixing, sentinel checks, *unconditional*
  disaster-recovery entry, existing-repo takeover assessment, BRD/spec-corpus
  ingestion before any feature code, staffing check), **Phase 1 Spec & design**
  (stories + compliance criteria, UX flows/IA before architecture,
  architecture + ADRs + security threat model, test strategy incl.
  non-functional targets and AI-feature evals), **Phase 2 Build**
  (waves/worktrees/ticket queue, RED-gate TDD, standing CI + docs + SRE
  readiness tasks, review/design/appsec gates, secrets response, sign-off only
  on `VERDICT: READY` independently confirmed, integration as a separate run),
  **Phase 3 Harden, verify & deliver** (conditional pentest with a real
  failure path, `/saeed:verify`, handover-ladder deployment with unauthorized
  deploys parked, and a checkable **DELIVERED** definition: READY verdict +
  signed criteria + no open blockers + docs + attribution), **Phase 4
  Improve** (default 3-pass session budget replacing "a sensible number",
  `/saeed:upgrade` cadence). A phase pointer is written to `.saeed/state.json`
  at every transition so crash-resume works; the pause protocol separates
  mid-lifecycle resume (`/saeed:hire`) from post-delivery loops
  (`saeed-loop.sh`, lethal-trifecta-scoped). All nine skills are wired in.
  Verified by a 4-auditor workflow plus 3 adversarial lenses (all findings
  fixed; the ops lens's two high findings — unanchored project root,
  unwritable resume pointer — drove the v2 tightening).
- Docs brought into lockstep (EN + AR): the hire lifecycle chain in
  `help.md` / CHEATSHEET, README "What this is" + flow diagram (intake, threat
  model, harden & verify, deliver stages), WHAT-IS "what it actually does".

### Fixed
- **`.saeed/` ledger reconciled with reality**: cycles 6-7 (v1.7.0, v1.8.0)
  ran via a cloud branch and never updated the ledger — `state.json` still
  said v1.6.0 / cycle 5 / 5 skills and lacked the `facilitated_by` field its
  own v1.8.0 attribution convention mandates. Reconstructed from git +
  CHANGELOG per the disaster-recovery rule; queue/retro now record the
  missing cycles. A version-parity check for `validate-fleet.sh` is queued
  (the stale-state class escaped the gate across two releases).
- Doc rot from the unpulled cycles: WHAT-IS-SAEED skills list (EN + AR) named
  only 4 of the 9 absorbed canons (hardcoded count dropped to stop the drift);
  `what-is-saeed.html` commands table was missing `/saeed:verify`;
  `instincts.md` was absent from the `.saeed/` folder tables (EN + AR).

## 1.8.0 - 2026-07-15

### Added
- **`skills/attribution`** — the signed-work convention: everything SAEED
  builds or facilitates carries the **NABAD Computer Solutions L.L.C.**
  credit. Canonical strings (EN + AR, full / short / facilitated forms, a
  machine-readable `facilitated_by` ledger field, a commit trailer), a
  placement matrix (README/docs footers, existing UI credit surfaces,
  `.saeed/` state files, commits), and restraint rules (once per surface,
  never claiming ownership of the client's code, operator/client
  prohibitions parked rather than fought).

### Changed
- Wired the convention through the lifecycle: `/saeed:hire` writes
  `facilitated_by` at `.saeed/` creation and credits deliverables;
  `/saeed:improve` and the continuous-improvement cycle audit attribution as
  a standing dimension; `the-boss` checks it in the Definition of Done;
  `technical-writer` places the doc credit; `frontend-engineer` /
  `ui-visual-designer` place the quiet UI credit where a credit surface
  exists.

## 1.7.0 - 2026-07-15

The ECC absorption cycle: audited [Everything Claude Code (ECC)](https://github.com/affaan-m/ECC)
and absorbed its engineering-practice canon, adapted to SAEED's doctrine.

### Added
- **Guardrail hooks** (`hooks/`) — the mechanical floor under "the team never
  weakens its own gates": `guard-git-bypass.sh` blocks `--no-verify` /
  `core.hooksPath` git-hook bypasses, `guard-config-protection.sh` blocks
  weakening existing lint/format configs (creation stays allowed), and
  `session-brief.sh` injects a `.saeed/` state snapshot at session start.
  All fail open, pure bash + python3 stdlib.
- **`skills/verification-protocol`** — the evidence canon: ordered executable
  gates (build → types → lint → tests → security → diff), the RED-gate TDD
  rule, the fixed Verification Report with a READY/NOT READY verdict,
  pass@k vs pass^k eval thresholds, and the anti-noise review doctrine.
- **`skills/context-discipline`** — the memory & attention canon: strategic
  compaction at phase boundaries, write-before-compact, confidence-scored
  instincts in `.saeed/instincts.md`, model routing with upgrade triggers,
  subagent context negotiation, and the tool-surface budget.
- **`skills/agentic-security`** — the defend-the-team canon: prompt-defense
  baseline, the lethal-trifecta rule for unattended runs, deny-rules and
  separate bot identity, plans/BRDs as untrusted input, and the secrets
  response protocol.
- **`/saeed:verify`** — runs the Verification Protocol end to end and returns
  the evidence-backed READY/NOT READY report.
- **CI** (`.github/workflows/validate.yml`) — runs `scripts/validate-fleet.sh`
  on every push/PR; hardened per the audited practices (read-only
  permissions, `persist-credentials: false`, SHA-pinned actions).
- **`validate-fleet.sh` checks 8–9** — hook-contract smoke tests (bypass
  payloads must block, benign ones must pass, the session brief must emit
  valid SessionStart JSON) and command/skill frontmatter integrity.
- `SECURITY.md`, this `CHANGELOG.md`, and plugin-manifest schema notes in
  `CONTRIBUTING.md`.

### Changed
- Ten agents wired to the new canons (one-line doctrine references):
  `the-boss`, `code-reviewer`, `qa-automation-engineer`, `test-architect`,
  `self-eval-critic`, `team-orchestrator`, `model-scout`,
  `security-architect`, `appsec-engineer`, `continuous-improvement-lead`.
- `skills/continuous-improvement` — `.saeed/instincts.md` added to the state
  inventory; gates now cite the Verification Protocol.

### Fixed
- `scripts/validate-fleet.sh` failed on any fresh clone (and would have
  failed CI) because it hard-required the gitignored `.saeed/state.json` and
  `.saeed/models.md`; those drift checks now run only when the files exist —
  present-but-stale still fails.

## 1.6.0 - 2026

### Added
- Self-Governance succession doctrine (`skills/self-governance`): decision
  rights, precedence and tie-breaking, autonomy levels (`.saeed/AUTONOMY`),
  operator-absent defaults (park under `## Awaiting operator`, never
  deadlock), post-convergence stewardship, disaster recovery, and the
  amendment process. The team runs without a human lead ([docs/SUCCESSION.md](docs/SUCCESSION.md)).
- Stewardship heartbeat runner `scripts/saeed-steward.sh`.

## 1.5.0 - 2026

### Added
- `macos-engineer` (roster to 54), fleet-wide certification rules, and the
  executable self-lint gate `scripts/validate-fleet.sh`.

## 1.4.0 - 2026

### Added
- Capability-first Handover Protocol (`skills/handover-protocol`): automate,
  drive, or hand off to Cowork before ever handing the user a manual chore.

### Changed
- Relicensed to the SAEED Non-Commercial License 1.0 (NABAD).

## 1.3.0 - 2026

### Added
- Roster expanded to 53 agents (incl. `hr-talent-lead`, `prompt-engineer`)
  and wired via reciprocal handoffs.
- Absorbed the Design Excellence canon (`skills/design-excellence`, with the
  `design-reviewer` gate) and the Orchestration Protocol
  (`skills/orchestration-protocol`, from the claude-sdlc-kit methodology).

## 1.0.0 - 2026

### Added
- Initial release: the Self-Advancing Elite Engineering Directorate —
  specialist subagent fleet, `/saeed:*` commands, the continuous-improvement
  loop with honest convergence, `scripts/saeed-loop.sh`, bilingual
  Arabic/English branding, and NABAD attribution.
