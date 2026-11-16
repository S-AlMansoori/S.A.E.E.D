@AGENTS.md

## Claude Code notes

- This file and `AGENTS.md` are instructions for working **on** this repository. The plugin that
  users install is defined by `.claude-plugin/`, `agents/`, `commands/`, `skills/` and `hooks/`.
- To try a change in a real session, add this checkout as a local marketplace and install it, as
  described in `CONTRIBUTING.md` ("Workflow", step 3). `hooks/hooks.json` registers the guard
  hooks on `Bash`, `Write`, `Edit` and `MultiEdit`, so with the plugin installed they also apply to
  edits made in this repository.
- Nothing else is Claude-specific; everything that matters is in `AGENTS.md`.
