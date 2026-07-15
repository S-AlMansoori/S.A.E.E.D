# Contributing to SAEED

Thanks for helping the directorate grow. This is a source-available project under the
**SAEED Non-Commercial License** (see [LICENSE](LICENSE)) — improvements of every size are welcome.
By contributing, you agree your contributions are licensed under that same license and that NABAD
Computer Solutions L.L.C. retains ownership of the project and any proceeds from it.

## Ground rules for agents

Each subagent lives in `agents/<name>.md` as YAML frontmatter + a Markdown system prompt.
Keep the fleet coherent:

1. **One crisp responsibility per agent.** Overlapping scopes are the #1 defect. If two agents
   fight over the same work, merge them or sharpen the boundary.
2. **Keyword-rich, action-oriented `description`.** It drives auto-delegation. Lead heavy-use
   agents with `MUST BE USED for ...`.
3. **Follow the section structure**: Scope (You own / Not yours) → Operating principles →
   Workflow → Output contract → Handoffs → Guardrails. It keeps agents predictable.
4. **Right-size the model.** Heavy reasoning → top tier; implementation → mid tier; lookups →
   fast tier. Don't hardcode a model you haven't confirmed exists.
5. **Scope tools tightly.** Review-only agents get read-only tools (no `Write`/`Edit`).
6. **Bilingual + a11y are non-negotiable** for any user-facing agent.
7. **Never weaken safety guardrails** to make an agent "more helpful."

## Workflow

1. Fork and branch.
2. Add/edit agents or commands. If you add an agent, update the roster table in `README.md`
   (or regenerate it).
3. Test locally: `/plugin marketplace add ./` then `/plugin install saeed@saeed-marketplace`,
   restart, and try the agent on a real task.
4. Bump `version` in `.claude-plugin/plugin.json` (semver: patch for fixes, minor for new
   agents, major for breaking changes).
5. Run `scripts/validate-fleet.sh` and make sure it exits 0. This is the executable
   fleet-consistency gate: it checks roster-count agreement across the README, manifests, and
   EN+AR docs (incl. Arabic numerals and the SVG badge), agent frontmatter (`name`/`description`/
   `model`, `name` matching the filename), the opus/sonnet tallies vs `.saeed/models.md`, JSON
   validity, that every `Handoffs` reference resolves, the hook contract (guardrail hooks must
   block bypass payloads and pass benign ones — smoke-tested with real stdin), and command/skill
   frontmatter. If you added an agent, this is what catches a count you forgot to bump. CI
   (`.github/workflows/validate.yml`) runs the same gate on every push and PR.
6. Update `CHANGELOG.md` (Keep-a-Changelog style, under the new version).
7. Open a PR describing what changed and why.

## Manifest gotchas (hard-won, don't re-learn them)

Claude Code's plugin validator has undocumented sharp edges (surfaced by the ECC project's
schema notes and confirmed by their regression history):

- **Never add an `agents` or `hooks` key to `.claude-plugin/plugin.json`.** `agents/*.md` and
  `hooks/hooks.json` are auto-discovered by convention; declaring them again is rejected
  (`agents: Invalid input`) or errors as a duplicate hooks file.
- `commands`/`skills`, if declared, must be **arrays** — a bare string is rejected.
- `version` is required; without it the install fails silently.

## Ground rules for hooks

Hooks in `hooks/` are guardrails, so they are held to the gate standard themselves:

- Pure `bash` + `python3` stdlib — no npm/pip installs, no network.
- **Fail open** (exit 0) on unparseable input or missing interpreter — a broken guardrail must
  never brick every tool call. Block with exit 2 and a reason on stderr.
- Every blocking behavior gets a smoke test in `scripts/validate-fleet.sh` check 8 — an
  untested hook is a hook that silently fails open forever.

## Ideas that are especially welcome

- New niche specialists (blockchain, embedded/IoT, game dev, data science, SRE deep-dives).
- Better eval/verification agents.
- Stack presets (e.g. a Django/Vue variant of the defaults).
- Localization beyond Arabic/English.

Be excellent to each other. 🩵

---

SAEED · سعيد — a product of **NABAD Computer Solutions L.L.C.** · نبض لحلول الكمبيوتر ذ.م.م.
SAEED Non-Commercial License 1.0 · © 2026 Saeed AlMansoori / NABAD.
