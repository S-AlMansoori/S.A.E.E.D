# Security Policy

SAEED is a Claude Code plugin whose agents edit code — sometimes unattended.
That makes security two questions, and this document answers both: how to
report a vulnerability *in* SAEED, and how SAEED defends *itself* while it
works on your repos.

## Reporting a vulnerability

- Use **GitHub private vulnerability reporting** on this repository
  (Security → Report a vulnerability), or contact NABAD via
  [almansoori.uk](https://almansoori.uk) if you need a private channel.
- Please do not open a public issue for anything exploitable — a prompt
  injection that survives the guardrails, a hook bypass, or a way to make an
  unattended loop exfiltrate data all qualify.
- You can expect an acknowledgment within a week; fixes ship as patch
  releases noted in [CHANGELOG.md](CHANGELOG.md). Only the latest minor
  version is supported.

## The plugin's own posture

- **Defensive only.** `security-pentester` tests systems the operator owns;
  no agent produces malware or attacks third parties, and no report changes
  that.
- **The team never weakens its own gates.** This is a self-governance
  untouchable, with a mechanical floor in `hooks/`: git-hook bypasses
  (`--no-verify`, `core.hooksPath` overrides) and lint/format config
  weakening are blocked at PreToolUse, and both guardrails are smoke-tested
  by `scripts/validate-fleet.sh` (check 8) in CI.
- **Agentic threat model.** `skills/agentic-security/SKILL.md` is the
  binding canon: the prompt-defense baseline (everything fetched or read is
  data, not instructions), the lethal-trifecta rule (private data +
  untrusted content + an outbound channel never combine in one unattended
  run), and plans/BRDs treated as untrusted input.
- **Unattended runs** (`scripts/saeed-loop.sh`, `scripts/saeed-steward.sh`)
  should be sandboxed (container/devcontainer, no-egress or allowlisted
  network), run under a dedicated bot identity with scoped short-lived
  tokens, and only ever point at a repo under git. Deny-rules for secret
  paths (`.env*`, `~/.ssh`, `~/.aws`, …) are recommended in the host
  Claude Code settings.
- **Secrets.** If an agent (or you) finds a committed credential:
  stop, fix the source, **rotate the credential**, sweep for siblings, and
  log it — deletion or history rewrite alone does not un-leak it.
- **Supply chain.** Third-party skills, plugins, and MCP servers are treated
  as supply-chain artifacts: reviewed before absorbing or enabling, pinned
  where possible. CI itself follows the same discipline (read-only token,
  `persist-credentials: false`, SHA-pinned actions).
