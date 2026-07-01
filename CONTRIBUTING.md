# Contributing to SAEED

Thanks for helping the directorate grow. This is a community-friendly, MIT-licensed project —
improvements of every size are welcome.

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
5. Open a PR describing what changed and why.

## Ideas that are especially welcome

- New niche specialists (blockchain, embedded/IoT, game dev, data science, SRE deep-dives).
- Better eval/verification agents.
- Stack presets (e.g. a Django/Vue variant of the defaults).
- Localization beyond Arabic/English.

Be excellent to each other. 🩵
