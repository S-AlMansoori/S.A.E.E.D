<div align="center">

# SAEED · سعيد

### Self-Advancing Elite Engineering Directorate

**A complete software engineering team you install into [Claude Code](https://docs.claude.com/en/docs/claude-code/overview) —
54 specialist AI engineers that design, build, test, secure, and document your project, then keep improving it on their own.**

<p>
  <img alt="version 1.8.0" src="https://img.shields.io/badge/version-1.8.0-C9A84C?style=flat-square&labelColor=0A1628" />
  <img alt="54 agents" src="https://img.shields.io/badge/agents-54-C9A84C?style=flat-square&labelColor=0A1628" />
  <img alt="Claude Code plugin" src="https://img.shields.io/badge/Claude_Code-plugin-0A1628?style=flat-square" />
  <img alt="bilingual" src="https://img.shields.io/badge/AR·EN-bilingual-C9A84C?style=flat-square&labelColor=0A1628" />
  <img alt="license non-commercial" src="https://img.shields.io/badge/license-non--commercial-0A1628?style=flat-square" />
</p>

**[📖 What is SAEED? (visual page, EN + العربية)](docs/what-is-saeed.html)** ·
**[⚡ Cheat sheet](docs/CHEATSHEET.md)** ·
Built by [Saeed AlMansoori](https://almansoori.uk)

**A product of NABAD Computer Solutions L.L.C. · نبض لحلول الكمبيوتر ذ.م.م**

</div>

---

## What this is

You hand SAEED a goal with one command — `/saeed:hire` — and it runs the whole lifecycle:
plans the architecture, splits the work across the right specialists, writes the code, reviews it,
tests it, hardens security, and documents everything. Then it **audits its own work and keeps
improving** until there's nothing worthwhile left to do, or you tell it to stop.

It does a few things most agent packs don't:

- 👔 **A micro-managing boss** (`the-boss`) that assigns work, demands evidence, and rejects anything half-done.
- ♻️ **A continuous-improvement loop** with an honest **convergence** stop — it won't invent busywork.
- 🧭 **Runs without a lead**: a **Self-Governance protocol** (decision rights, tie-breaking, autonomy levels, operator-absent defaults, disaster recovery) plus a stewardship heartbeat (`scripts/saeed-steward.sh` on cron) keep the team un-deadlocked with nobody watching and keep a *finished* project alive forever. The retiring lead's handover lives in [docs/SUCCESSION.md](docs/SUCCESSION.md).
- 🧬 **Self-upgrade**: `model-scout` moves the team onto stronger models as they ship; `hr-talent-lead` spots capability gaps and `roster-maintainer` adds/retires agents; `agent-optimizer` sharpens their prompts.
- 🎨 **Absorbed design taste**: an elite **Design Excellence** canon (distilled from `impeccable`, `gpt-taste`, `emil-design-eng`, and more) is baked into every UI agent and enforced by a dedicated `design-reviewer` gate — so the UI never looks AI-generated, without you having to ask.
- 🧩 **Absorbed delivery discipline**: an **Orchestration Protocol** (distilled from the `claude-sdlc-kit`) runs parallel work in worktree-isolated waves off a shared ticket queue, keeps integration a separate gated run, and does adversarial parallel-browser QA.
- 🔬 **Absorbed evidence discipline**: a **Verification Protocol**, **Context Discipline**, and **Agentic Security** canon (distilled from [Everything Claude Code](https://github.com/affaan-m/ECC)) — ordered executable gates ending in a READY/NOT READY verdict (`/saeed:verify`), strategic compaction + confidence-scored instincts, and a defend-the-team threat model — plus **guardrail hooks** that mechanically block git-gate bypasses and lint-config weakening, smoke-tested in CI.
- 🤲 **Capability-first, manual-last**: a **Handover Protocol** means SAEED won't hand you a chore it could do itself — before any "you go do X", it does it in-session, drives it (browser / desktop / a connector), or hands it to **Cowork** (when you have it) as a paste-and-run packet. Only the genuinely human-only (a credential, money movement) comes back to you, with the reason and exact steps.
- 📱 **Web + native mobile**: web (React/Next), plus dedicated **native iOS** (Swift/SwiftUI) and **native Android** (Kotlin/Compose) engineers — not just cross-platform.
- 🖥️ **Owns the metal**: dedicated **networking** and **AI-systems** engineers (Docker, NVIDIA DGX Spark, GPU/CUDA, vLLM/Ollama) for the air-gapped stack.
- 🌐 **Bilingual by design**: Arabic/English + RTL correctness is baked into every user-facing agent.
- 🏷️ **Signed work**: everything SAEED builds or facilitates carries the **NABAD Computer Solutions L.L.C.** credit — README/docs footers, UI credit surfaces, the state ledger, and commit trailers — per a canonical convention (`skills/attribution/SKILL.md`): once per surface, never claiming ownership of your code.

## 💸 What it saves (UAE, AED)

To do what SAEED does, a company hires a team. At 2026 UAE mid-market salaries:

```text
Human team — fully loaded   ████████████████████████████████████████  ≈ AED 5,700,000 / yr
Human team — base salaries  ██████████████████████████████            ≈ AED 4,224,000 / yr
SAEED (Claude Max 20x)      ▏                                         ≈ AED     8,820 / yr
                            └───────────────────────────────────────  ~480–650× cheaper (≈0.15% of payroll)
```

That last bar really is a hairline — that's the point. Full breakdown, both languages, and nicer
charts in **[docs/what-is-saeed.html](docs/what-is-saeed.html)**.
*(Illustrative mid-market figures; SAEED augments you rather than being a literal headcount swap.)*

## 🔄 How the work flows

```mermaid
flowchart LR
    H(["/saeed:hire"]):::cmd --> S["product-engineer<br/>spec"]
    S --> A["principal-architect<br/>design + ADRs"]
    A --> O["team-orchestrator<br/>route work"]
    O --> B["specialists<br/>build (worktree waves)"]
    B --> G{"code-reviewer + design-reviewer<br/>+ tests"}
    G -- pass --> K["the-boss<br/>sign off on evidence"]
    G -- fail --> B
    K --> I["continuous-improvement-lead<br/>audit + queue next"]
    I --> B
    I -- "nothing worthwhile left" --> C(["CONVERGED"]):::done
    I -. "every few cycles (you approve)" .-> U["model-scout · roster-maintainer<br/>agent-optimizer · hr-talent-lead<br/>self-upgrade"]:::meta
    U -. "stronger models + roster" .-> B
    K -. "you run /saeed:stop" .-> X(["STOP"]):::stop
    classDef cmd fill:#C9A84C,stroke:#0A1628,color:#0A1628,font-weight:bold;
    classDef done fill:#0A1628,stroke:#C9A84C,color:#F5F1E6;
    classDef stop fill:#7a2e2e,stroke:#C9A84C,color:#ffffff;
    classDef meta fill:#1b2d4d,stroke:#C9A84C,color:#F5F1E6,stroke-dasharray:4 3;
```

## 🚀 Install

Requires the Claude Code CLI.

```bash
# 1. Register this repo as a plugin marketplace (local path, or owner/repo once pushed)
/plugin marketplace add S-AlMansoori/S.A.E.E.D
#   (or from a local clone:)  /plugin marketplace add /path/to/S.A.E.E.D

# 2. Install the plugin
/plugin install saeed@saeed-marketplace
```

Restart the session, then run `/agents` to see all 54.

## 🎛️ Commands

| Command | What it does |
|---|---|
| `/saeed:hire <goal>` | Take a project from zero to done, then keep improving it. **Start here.** |
| `/saeed:improve` | Run improvement passes (audit → fix → verify → repeat). The self-improvement button. |
| `/saeed:verify` | Run the Verification Protocol gates and get an evidence-backed READY / NOT READY report. |
| `/saeed:status` | A blunt, no-spin status report from the Boss. |
| `/saeed:upgrade` | The team upgrades itself: better models + add/retire its own agents. |
| `/saeed:stop` | Halt the autonomous loop. |
| `/saeed:help` | Show the cheat sheet. |

Or just **ask in plain English or Arabic** — *"use the rag-architect to design retrieval for this
corpus"* — and the right specialist is picked automatically.

## 🤖 Truly autonomous (unattended) mode

Claude Code subagents run inside a session — they don't self-trigger 24/7. For genuine hands-off
operation, point the runner at a repo. It runs `/saeed:improve` every cycle until the team writes
`.saeed/CONVERGED`, you drop a `.saeed/STOP` file, or it hits the cap:

```bash
scripts/saeed-loop.sh /path/to/your/repo 50 0
#                       repo               max  sleep(sec)
```

Wire it to `cron` or CI for scheduled improvement. ⚠️ It edits files unattended — only run it on a
repo under git.

When the team writes `.saeed/CONVERGED`, the loop stops — that's success, not death. To keep a
converged repo alive indefinitely, cron the **stewardship heartbeat** instead:

```bash
scripts/saeed-steward.sh /path/to/your/repo   # weekly is the sane default
```

It re-runs the executable gates, checks the reopen triggers written into `CONVERGED`, and wakes
the full loop only when one fires or a gate goes red. Approvals it can't get are parked under
`## Awaiting operator` in `.saeed/queue.md` — an unattended pass never deadlocks (see
`skills/self-governance/SKILL.md`).

**If you only ever schedule one thing, schedule the steward** — it handles both cases (it runs a
normal improvement pass on a not-yet-converged repo and a heartbeat once converged), so you can't
be caught by the loop going silent the day it converges.

### The `.saeed/` folder (the team's shared memory, created in your project)

| File | Holds |
|---|---|
| `queue.md` | Backlog: each item's owner, acceptance criteria, status. |
| `state.json` | Machine-readable ledger + cycle count. |
| `retro.md` | Retrospectives and learnings. |
| `instincts.md` | Confidence-scored, atomic learnings (trigger → action) per the Context Discipline canon. |
| `models.md` | Which agent runs on which model (+ history). |
| `CONVERGED` | Appears when nothing worthwhile is left to improve (with reasons + reopen triggers). |
| `STOP` | You create this to halt. Delete it to resume. |
| `AUTONOMY` | Autonomy level. Absent/`supervised`: self-modification parks for your approval; `autonomous`: the team may land it unattended (gated, logged, reversible). |

## 👥 The roster (54 agents)

Heavy-reasoning roles run on the top tier (Opus); implementers run on the mid tier (Sonnet).
`model-scout` re-tiers the fleet when better models become available.

### Governance & Meta
| Agent | Model | Role |
|---|---|---|
| `the-boss` | opus | Enforces accountability — assigns, chases, signs off on evidence |
| `team-orchestrator` | opus | Decomposes goals and routes work to the right specialist |
| `hr-talent-lead` | opus | HR/staffing — detects capability gaps, commissions new agents |
| `roster-maintainer` | opus | Adds, retires, or reshapes the team's own agents |
| `model-scout` | sonnet | Keeps the team on the best available models |
| `continuous-improvement-lead` | opus | Drives the improvement loop; decides convergence |
| `agent-optimizer` | opus | Improves the agents' own prompts |
| `prompt-engineer` | opus | Prompt craft for users + the inter-agent communication layer |
| `self-eval-critic` | opus | Independently verifies gains; runs retros (read-only) |

### Architecture & Product
| Agent | Model | Role |
|---|---|---|
| `principal-architect` | opus | System design, tech choices, and ADRs |
| `product-engineer` | sonnet | Turns ideas/BRDs into buildable specs |

### Frontend & Mobile
| Agent | Model | Role |
|---|---|---|
| `frontend-engineer` | sonnet | Builds and modifies web UI (React/Next) |
| `react-native-engineer` | sonnet | Cross-platform mobile (Expo/React Native) |
| `ios-engineer` | sonnet | Native iOS (Swift/SwiftUI) |
| `android-engineer` | sonnet | Native Android (Kotlin/Jetpack Compose) |
| `macos-engineer` | sonnet | Native macOS desktop (SwiftUI/AppKit) + Developer ID notarization |
| `frontend-performance-engineer` | sonnet | Diagnoses and fixes frontend performance |
| `accessibility-specialist` | sonnet | Audits and fixes accessibility (WCAG) |
| `pwa-offline-engineer` | sonnet | PWA and offline-first work |

### Design
| Agent | Model | Role |
|---|---|---|
| `product-designer` | sonnet | UX flows, wireframes, interaction design |
| `ui-visual-designer` | opus | Visual and brand design (navy/gold) |
| `design-systems-engineer` | sonnet | Builds and maintains the design system |
| `design-reviewer` | opus | Design-excellence gate for user-facing diffs (read-only) |
| `ux-researcher` | sonnet | Plans and analyzes user research |

### Backend
| Agent | Model | Role |
|---|---|---|
| `backend-engineer` | sonnet | Builds server-side logic |
| `api-designer` | sonnet | Designs API contracts |
| `realtime-engineer` | sonnet | Realtime and event-driven features |
| `edge-serverless-engineer` | sonnet | Edge/serverless (Cloudflare Workers/Pages) |

### Data & Databases
| Agent | Model | Role |
|---|---|---|
| `database-architect` | sonnet | Data modeling, schema, RLS, migrations |
| `query-optimization-engineer` | sonnet | Diagnoses and fixes slow queries |
| `vector-search-engineer` | sonnet | Embeddings + vector search (bilingual) |
| `data-engineer` | sonnet | Pipelines, ETL, OCR digitization |

### AI / ML
| Agent | Model | Role |
|---|---|---|
| `llm-engineer` | opus | LLM app work (prompts, tools, evals) |
| `rag-architect` | opus | Designs and improves RAG end-to-end |
| `ml-engineer` | sonnet | Model selection, fine-tuning, evaluation |
| `mlops-engineer` | sonnet | Serves/operates models (vLLM on the DGX) |
| `nlp-bilingual-specialist` | sonnet | Arabic/English NLP correctness |

### Security
| Agent | Model | Role |
|---|---|---|
| `security-architect` | opus | Threat modeling and authZ/ABAC design |
| `appsec-engineer` | sonnet | Finds and fixes app vulnerabilities (OWASP) |
| `devsecops-engineer` | sonnet | Secures the pipeline and runtime |
| `security-pentester` | sonnet | Tests your OWN systems (defensive only) |

### Infrastructure & Ops
| Agent | Model | Role |
|---|---|---|
| `devops-platform-engineer` | sonnet | CI/CD, the developer platform, gated integration |
| `cloud-infra-engineer` | sonnet | Infrastructure as code, provisioning |
| `network-engineer` | sonnet | Networking, segmentation, DNS/TLS, air-gap isolation |
| `ai-systems-engineer` | sonnet | Docker + NVIDIA DGX Spark + GPU/CUDA + AI tooling |
| `sre-observability-engineer` | sonnet | Reliability, SLOs, monitoring, incidents |

### Quality
| Agent | Model | Role |
|---|---|---|
| `qa-automation-engineer` | sonnet | Writes automated tests (unit/integration/E2E) |
| `test-architect` | sonnet | Sets test strategy and coverage plan |
| `code-reviewer` | sonnet | Reviews diffs before they're accepted (read-only) |

### Specialists
| Agent | Model | Role |
|---|---|---|
| `python-engineer` | sonnet | Python (FastAPI, async, tooling) |
| `typescript-specialist` | sonnet | Advanced TypeScript / precise types |
| `technical-writer` | sonnet | Documentation (bilingual) |
| `i18n-localization-engineer` | sonnet | RTL layout and locale formatting |
| `compliance-privacy-engineer` | sonnet | PII, privacy, retention (UAE-aware) |

## 🛡️ Safety & guardrails

This team edits code and, in the loop, does so repeatedly. It's built with rails, but **you own the
blast radius**:

- **Version-control everything** and only run the loop on a clean git repo so you can review and revert.
- **Self-modification needs approval by default** — `/saeed:upgrade` proposes model/roster changes and waits for you (or parks them under `## Awaiting operator` if you're away). Set `.saeed/AUTONOMY` to `autonomous` only if you want those changes landed unattended — still gated, logged, and reversible.
- **The team never disables its own review/test/security gates**, and `self-eval-critic` independently checks that gains are real. Guardrail hooks make the git half of that mechanical: `--no-verify` / `core.hooksPath` bypasses and lint-config weakening are blocked at the tool level (see `hooks/` and [SECURITY.md](SECURITY.md)).
- **Security is defensive only.** `security-pentester` tests systems *you own*; the security agents won't produce malware or attack third parties.
- **Convergence is a feature** — the loop is designed to *stop* when returns diminish.

Nothing here is legal advice; `compliance-privacy-engineer` flags issues, but consult qualified
counsel for legal questions.

## 🧩 Customize

- Change the tagline in `.claude-plugin/plugin.json`.
- Add or edit agents in `agents/` — or ask `roster-maintainer` to do it.
- Adjust model tiers per agent's `model:` frontmatter — or let `model-scout` manage it.

## 🤝 Contributing

PRs welcome — new specialists, better prompts, fixes. See [CONTRIBUTING.md](CONTRIBUTING.md).

## 📄 License

**SAEED Non-Commercial License 1.0** — © 2026 Saeed AlMansoori · **NABAD Computer Solutions L.L.C.**
(نبض لحلول الكمبيوتر ذ.م.م). Source-available and free to use, modify, and share for **personal,
educational, and non-commercial** use. **Commercial use is not permitted without NABAD's written
permission**, and NABAD owns any proceeds made from SAEED, directly or indirectly. See
[LICENSE](LICENSE); for a commercial license, contact [NABAD](https://almansoori.uk).
*(This is a summary, not legal advice — the [LICENSE](LICENSE) file governs.)*
