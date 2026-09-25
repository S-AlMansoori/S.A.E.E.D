# SAEED on OpenAI Codex

SAEED is built for Claude Code, but most of it runs in [OpenAI Codex](https://learn.chatgpt.com/docs/plugins)
too. This page covers what installs as a Codex plugin, how to add the 55 specialist agents, and
what doesn't carry over one-to-one.

Everything Codex-specific is **generated** from the Claude sources by `scripts/gen-codex.sh`, so
the two stay in step. The generated files are `codex/` and `.codex-plugin/plugin.json`; `--check`
fails CI if they drift.

## 1. Install the plugin

```bash
codex plugin marketplace add S-AlMansoori/S.A.E.E.D
```

Then open the plugin browser in Codex and install **SAEED** from the `saeed-marketplace`
marketplace. The marketplace entry is `.agents/plugins/marketplace.json`, and the plugin manifest
is `.codex-plugin/plugin.json`. Its `version` is always copied from `.claude-plugin/plugin.json`.

## 2. What works natively

| SAEED piece | In Codex | How to use it |
|---|---|---|
| **19 canons** (`skills/*/SKILL.md`) | Skills. Codex reads the same `SKILL.md` format. | Codex loads them automatically when relevant, or you name one: `$verification-protocol`, `$attribution`, `$app-hardening` … |
| **7 commands** (`/saeed:*`) | Skills called `saeed-<cmd>`. Implicit invocation is off, so they only run when you call them. | `$saeed-hire build a bilingual booking app`, `$saeed-verify`, `$saeed-improve`, `$saeed-status`, `$saeed-upgrade`, `$saeed-stop`, `$saeed-help` |
| **Guardrail hooks** (`hooks/hooks.json`) | Plugin hooks. Codex sets `CLAUDE_PLUGIN_ROOT` so the existing hook commands resolve, and exit code 2 blocks the action. | Automatic: git-gate bypasses, lint-config weakening, and brand-name corruption on Arabic surfaces are blocked for shell commands and for file edits, including Codex's `apply_patch`. |

## 3. Install the 55 agents (Codex custom agents)

Codex plugins can bundle skills, MCP servers and hooks. They **cannot bundle agents**, so the
agents are installed separately. You need a clone of this repo:

```bash
git clone https://github.com/S-AlMansoori/S.A.E.E.D && cd S.A.E.E.D
scripts/gen-codex.sh --install --user          # links into ~/.codex/agents/ (every project)
# or, for one project only:
scripts/gen-codex.sh --install /path/to/project   # links into /path/to/project/.codex/agents/
```

The installer creates symlinks to `codex/agents/*.toml`, so a `git pull` updates the agents too.
It is safe to run again. It never overwrites a file that isn't a symlink: it skips that file,
reports it, and exits 1.

To use an agent, name it in your request, e.g. *"have `code-reviewer` review this diff"* or
*"spawn `rag-architect` to design retrieval"*. Commands such as `$saeed-hire` delegate to these
agents by name. If an agent isn't installed, Codex does that role's work itself under the same
rules.

## 4. What does not translate one-to-one

| Claude Code | Codex equivalent | Notes |
|---|---|---|
| `/saeed:hire` | `$saeed-hire` | Codex has no plugin slash commands. `$ARGUMENTS` becomes the text after the skill name. |
| `model: opus` / `fable` / `sonnet` | `model_reasoning_effort = "high"` / `"high"` / `"medium"` | Claude model names mean nothing to Codex, so no `model` is set. Each agent uses your Codex model at the mapped effort. `/saeed:upgrade`'s model re-tiering only applies to Claude Code. |
| Per-agent `tools:` allowlist | `sandbox_mode = "read-only"` when the agent has no `Write`, `Edit` or `Bash` | This is only an approximation. Codex has no per-tool allowlist, so read-only reviewers stay read-only and every other agent inherits your session's sandbox. |
| `Task`-style subagent delegation | Codex subagent spawning | Codex decides when to spawn. Ask for an agent by name for reliable delegation. |
| `scripts/saeed-loop.sh`, `saeed-steward.sh` | — | These drive the `claude` CLI. There is no Codex runner yet. |

## 5. For contributors

After editing `agents/`, `commands/`, `skills/` or the Claude manifest version, run:

```bash
scripts/gen-codex.sh           # regenerate codex/ and .codex-plugin/plugin.json
scripts/gen-codex.sh --check   # exits 1 on drift (wired into the fleet validator)
```

Never edit anything under `codex/` by hand.

## 6. Sources (verified 2026-09-25)

The Codex docs moved from `developers.openai.com/codex/*` to `learn.chatgpt.com/docs/*`.

- Plugins: https://learn.chatgpt.com/docs/plugins
- Building plugins (manifest, `.codex-plugin/plugin.json` fallback, marketplace): https://developers.openai.com/plugins/build/plugins
- Skills (`SKILL.md`, `$skill` invocation, `agents/openai.yaml`): https://learn.chatgpt.com/docs/build-skills
- Subagents / custom agents (TOML fields, `sandbox_mode`, `model_reasoning_effort`): https://learn.chatgpt.com/docs/agent-configuration/subagents
- Hooks (plugin `hooks/hooks.json`, `apply_patch` matcher, `CLAUDE_PLUGIN_ROOT` alias): https://learn.chatgpt.com/docs/hooks
- AGENTS.md (32 KiB combined default cap): https://learn.chatgpt.com/docs/agent-configuration/agents-md
- Config reference: https://learn.chatgpt.com/docs/config-file/config-reference

---

SAEED · سعيد — a product of **NABAD Computer Solutions L.L.C.** · نبض لحلول الكمبيوتر ذ.م.م.
SAEED Non-Commercial License 1.0 · © 2026 Saeed AlMansoori / NABAD.
