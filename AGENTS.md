# AGENTS.md — working on the SAEED repo

Instructions for OpenAI Codex and any other AGENTS.md-aware agent that edits **this repository**.
(Claude Code users: the same rules live in [CONTRIBUTING.md](CONTRIBUTING.md).)

## What this repo is

SAEED (سعيد, *Self-Advancing Elite Engineering Directorate*) is a **Claude Code plugin**: 55
specialist subagents, 7 `/saeed:*` commands, 19 skill "canons", and guardrail hooks. It also
ships an **OpenAI Codex compatibility layer** that is *generated* from the Claude sources — see
[docs/CODEX.md](docs/CODEX.md). There is no application to build; the product is the Markdown,
JSON, and shell in this tree, and the executable gate is `scripts/validate-fleet.sh`.

## Layout

| Path | What it is |
|---|---|
| `agents/<name>.md` | One subagent: YAML frontmatter (`name`, `description`, `model`, `tools`) + system prompt. `name` must equal the filename. |
| `commands/<cmd>.md` | The `/saeed:<cmd>` slash commands (frontmatter `description`, body uses `$ARGUMENTS`). |
| `skills/<canon>/SKILL.md` | The 19 canons (doctrine the agents apply). |
| `hooks/` | Guardrail hooks + `hooks.json` (bash + python3 stdlib, fail-open). |
| `scripts/validate-fleet.sh` | The fleet-consistency gate — must exit 0. |
| `scripts/gen-codex.sh` | Generates the Codex layer; `--check` fails on drift. |
| `codex/`, `.codex-plugin/plugin.json` | **Generated** Codex agents (TOML), command skills, canon symlinks, manifest. Never hand-edit. |
| `.claude-plugin/` | Claude Code plugin + marketplace manifests (source of the version). |
| `.agents/plugins/marketplace.json` | Codex marketplace entry. |
| `docs/` | User docs (EN + AR). `README.md`, `CHANGELOG.md` at root. |

## Non-negotiable rules

Full text and rationale: [CONTRIBUTING.md](CONTRIBUTING.md). In short:

1. **One crisp responsibility per agent**; keyword-rich, action-oriented `description`s.
2. Agent sections follow: Scope → Operating principles → Workflow → Output contract → Handoffs → Guardrails.
3. Right-size the model tier; never hardcode a model that isn't confirmed to exist.
4. Scope tools tightly — review-only agents get no `Write`/`Edit`.
5. Bilingual (Arabic/English) and accessibility are non-negotiable for user-facing work.
6. **Never weaken a safety guardrail** (hooks, lint configs, git gates) to make something pass.
7. Never add `agents` or `hooks` keys to `.claude-plugin/plugin.json`; `commands`/`skills`, if
   declared there, must be arrays. `version` is required.
8. Hooks: pure bash + python3 stdlib, no network, fail open (exit 0) on bad input, block with
   exit 2 + a reason on stderr, and every blocking behavior gets a smoke test in the validator.
9. Adding/removing an agent means updating every surface that states the count — the
   validator catches the ones you miss.
10. Bump `version` in `.claude-plugin/plugin.json` (semver) and add a `CHANGELOG.md` entry
    (Keep-a-Changelog) for every shipped change.

## Before you say "done"

```bash
scripts/gen-codex.sh            # after ANY edit to agents/, commands/, skills/ or the manifest version
scripts/validate-fleet.sh       # must exit 0
scripts/gen-codex.sh --check    # must print OK (no drift between sources and codex/)
```

Report the actual output; "it should pass" is not evidence.

## Attribution canon (read before writing any Arabic)

Read [`skills/attribution/SKILL.md`](skills/attribution/SKILL.md) before touching a credit line,
footer, or any Arabic surface, and **copy** its strings — never retype them from memory.
The company's Arabic name is **نبض** — an Arabic word, never a transliteration of "NABAD".
The misspellings listed in that skill are wrong names, not variants; the validator (check 14)
and a guardrail hook reject them — so don't quote them here either.

Docs end with this footer, copied exactly:

```
SAEED · سعيد — a product of **NABAD Computer Solutions L.L.C.** · نبض لحلول الكمبيوتر ذ.م.م.
SAEED Non-Commercial License 1.0 · © 2026 Saeed AlMansoori / NABAD.
```

## Licence

Source-available under the SAEED Non-Commercial License 1.0 ([LICENSE](LICENSE)). Contributions
are accepted under the same licence.

---

SAEED · سعيد — a product of **NABAD Computer Solutions L.L.C.** · نبض لحلول الكمبيوتر ذ.م.م.
SAEED Non-Commercial License 1.0 · © 2026 Saeed AlMansoori / NABAD.
