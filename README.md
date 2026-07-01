# SAEED — Self-Advancing Elite Engineering Directorate

> **S.A.E.E.D.** · *Self-Advancing Elite Engineering Directorate* — a full, self-improving
> software team you install into [Claude Code](https://docs.claude.com/en/docs/claude-code/overview).
> 46 specialist AI subagents across every discipline a modern product needs, plus a
> governance layer that keeps them honest — and can upgrade **itself**.

Built by [Saeed AlMansoori](https://almansoori.uk). MIT licensed. Fork it, use it, improve it.

---

## What this is

SAEED is a Claude Code **plugin** that bundles a complete engineering org as subagents. You
hand it a goal or a repo; the team designs, builds, reviews, tests, secures, documents — and
then keeps improving the project on its own until there's genuinely nothing worthwhile left to
do (or you tell it to stop).

It includes things most agent packs don't:

- **A micro-managing boss** (`the-boss`) that assigns work, demands evidence, and rejects
  anything half-done.
- **A continuous-improvement loop** (`continuous-improvement-lead` + `/saeed:improve`) with an
  honest **convergence** stop condition — it won't invent busywork.
- **Self-upgrade**: `model-scout` moves the team onto stronger models as they ship;
  `roster-maintainer` adds/prunes agents; `agent-optimizer` sharpens their prompts.
- **Bilingual by default**: Arabic/English + RTL correctness is baked into every user-facing
  agent.

## The roster (46 agents)

### Governance & Meta

| Agent | Model | Role |
|---|---|---|
| `the-boss` | opus | Enforce accountability across the team |
| `team-orchestrator` | opus | The entry point for any multi-step project |
| `roster-maintainer` | opus | The team itself needs to change |
| `model-scout` | sonnet | Keep the team on the best available models |
| `continuous-improvement-lead` | opus | Drive the perpetual improvement loop on a handed-over project |
| `agent-optimizer` | opus | Improve the SAEED agents themselves |
| `self-eval-critic` | opus | Independently judge the team's own output quality |

### Leadership & Product

| Agent | Model | Role |
|---|---|---|
| `principal-architect` | opus | MUST BE USED before significant build work for system design |
| `product-engineer` | sonnet | Turn requirements, BRDs, or rough ideas into buildable specs |

### Frontend

| Agent | Model | Role |
|---|---|---|
| `frontend-engineer` | sonnet | Build and modify web UI |
| `react-native-engineer` | sonnet | Mobile app work |
| `frontend-performance-engineer` | sonnet | Diagnose and fix frontend performance |
| `accessibility-specialist` | sonnet | Audit and fix accessibility |
| `pwa-offline-engineer` | sonnet | Progressive Web App and offline-first work |

### Design

| Agent | Model | Role |
|---|---|---|
| `product-designer` | sonnet | UX |
| `ui-visual-designer` | opus | Visual and brand design |
| `design-systems-engineer` | sonnet | Build and maintain the design system |
| `ux-researcher` | sonnet | Plan and analyze user research |

### Backend

| Agent | Model | Role |
|---|---|---|
| `backend-engineer` | sonnet | Build server-side logic |
| `api-designer` | sonnet | Design API contracts |
| `realtime-engineer` | sonnet | Realtime and event-driven features |
| `edge-serverless-engineer` | sonnet | Edge/serverless work |

### Data & Databases

| Agent | Model | Role |
|---|---|---|
| `database-architect` | sonnet | Data modeling and schema |
| `query-optimization-engineer` | sonnet | Diagnose and fix slow database queries |
| `vector-search-engineer` | sonnet | Embeddings and vector search |
| `data-engineer` | sonnet | Data pipelines |

### AI / ML

| Agent | Model | Role |
|---|---|---|
| `llm-engineer` | opus | LLM application work |
| `rag-architect` | opus | Design and improve RAG systems end to end |
| `ml-engineer` | sonnet | Classical/deep ML |
| `mlops-engineer` | sonnet | Serve and operate models |
| `nlp-bilingual-specialist` | sonnet | Arabic/English NLP |

### Security

| Agent | Model | Role |
|---|---|---|
| `security-architect` | opus | Security design |
| `appsec-engineer` | sonnet | Find and fix application vulnerabilities |
| `devsecops-engineer` | sonnet | Secure the pipeline and runtime |
| `security-pentester` | sonnet | Validate defenses against the team's OWN systems |

### Infrastructure & Ops

| Agent | Model | Role |
|---|---|---|
| `devops-platform-engineer` | sonnet | CI/CD and developer platform |
| `cloud-infra-engineer` | sonnet | Provision and manage infrastructure as code |
| `sre-observability-engineer` | sonnet | Reliability and observability |

### Quality

| Agent | Model | Role |
|---|---|---|
| `qa-automation-engineer` | sonnet | Write automated tests |
| `test-architect` | sonnet | Set test strategy |
| `code-reviewer` | sonnet | MUST BE USED after writing or modifying code |

### Specialists

| Agent | Model | Role |
|---|---|---|
| `python-engineer` | sonnet | Python work |
| `typescript-specialist` | sonnet | Advanced TypeScript |
| `technical-writer` | sonnet | Documentation |
| `i18n-localization-engineer` | sonnet | Internationalization/localization |
| `compliance-privacy-engineer` | sonnet | Data privacy and compliance |

Heavy-reasoning roles (architecture, orchestration, AI/RAG design, security design, the boss)
run on the top tier; implementers run on the mid tier. `model-scout` re-tiers the fleet when
better models become available and accessible.

---

## Install

Requires the Claude Code CLI. Then, from anywhere:

```bash
# 1. Register this repo as a plugin marketplace (local path, or owner/repo once pushed)
/plugin marketplace add S-AlMansoori/S.A.E.E.D
#   (or from a local clone:)  /plugin marketplace add /path/to/S.A.E.E.D

# 2. Install the plugin
/plugin install saeed@saeed-marketplace
```

Restart the session so the agents load. Run `/agents` to see them all.

## Use it

**One command to start** — hand it a project and it does the rest (design → build → test →
secure → document → improve):

```
/saeed:hire  <what you want built, or a path to a spec/repo>
```

**All the commands (plain names, one job each):**

| Command | What it does |
|---|---|
| `/saeed:hire <goal>` | Take a project from zero to done, then keep improving it. **Start here.** |
| `/saeed:improve` | Run improvement passes (audit → fix → verify → repeat). The self-improvement button. |
| `/saeed:status` | Blunt status report from the Boss. |
| `/saeed:upgrade` | Team upgrades itself: better models + add/retire its own agents. |
| `/saeed:stop` | Halt the autonomous loop. |
| `/saeed:help` | Show the cheat sheet. |

**Or just ask in plain English or Arabic** — e.g. *"use the rag-architect to design retrieval
for this corpus"* — and the right specialist is picked automatically.

📄 **New here? Read [What is SAEED?](docs/WHAT-IS-SAEED.md) (English + العربية, with the AED
cost-savings breakdown) and the [Cheat Sheet](docs/CHEATSHEET.md).**

## Truly autonomous (unattended) mode

Claude Code subagents run inside a session — they don't self-trigger 24/7. To get genuine
hands-off operation, point the included runner at a repo. It runs `/saeed:improve` every cycle
until the improvement lead writes `.saeed/CONVERGED`, you drop a `.saeed/STOP` file, or it hits
the cycle cap:

```bash
scripts/saeed-loop.sh /path/to/your/project 50 0
#                       repo                  max_cycles  sleep_seconds
```

Wire that to `cron` or CI for scheduled, continuous improvement. **Read the safety section
first** — unattended mode grants file-editing permission.

### The `.saeed/` state directory

Each managed repo gets a `.saeed/` folder the team uses as shared memory: `queue.md` (backlog),
`state.json` (ledger), `retro.md` (learnings), `models.md` (tiering), plus `CONVERGED` / `STOP`
sentinels. See the `continuous-improvement` skill for the full protocol.

---

## Safety & guardrails (read this)

This team can edit code and, in the loop, do so repeatedly. It's built with rails, but **you
own the blast radius**:

- **Version control everything.** Only run the autonomous loop on a repo with clean git state
  so you can review and revert.
- **Self-modification needs approval by default.** `/saeed:upgrade` proposes model/roster
  changes and waits for you unless you explicitly enable autonomous self-modification.
- **The team never disables its own review/test/security gates** to make progress, and
  `self-eval-critic` independently checks that "improvements" are real.
- **Security is defensive only.** `security-pentester` tests systems *you own*; the security
  agents will not produce malware or attack third parties.
- **Convergence is a feature.** The loop is designed to *stop* when returns diminish.

Nothing here is legal or compliance advice; the `compliance-privacy-engineer` flags issues but
you should consult qualified counsel for legal questions.

## Customize

- Change the tagline/name in `.claude-plugin/plugin.json`.
- Add or edit agents in `agents/` — or just ask `roster-maintainer` to do it.
- Adjust model tiers in each agent's `model:` frontmatter — or let `model-scout` manage it.
- Set your GitHub username/repo in `plugin.json` `repository` and the install commands above
  (already set to `S-AlMansoori/S.A.E.E.D`).

## Contributing

PRs welcome — new specialists, better prompts, bug fixes. See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT © 2026 Saeed AlMansoori. Share it freely with friends, family, and the community.
