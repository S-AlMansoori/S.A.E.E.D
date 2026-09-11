# SAEED Capability Map

Every engineering capability SAEED covers, its **owner** (the agent whose scope
claims it), and the **doctrine/gate** that enforces it. This map exists because
cycle 11 proved an unowned capability is structurally invisible: the roster
tables inventory *agents*, so nothing failed when backups, load testing, and
named compliance regimes had no owner at all. This file is the artifact that
fails instead — `scripts/validate-fleet.sh` Check 13 asserts every backticked
agent named here exists in `agents/`.

**Rules of the map.** One primary owner per capability, helpers and requirement-setters in parentheses; per-platform rows name one owner per platform.
A capability with no owner row is a defect: add the row and, if no agent claims
it, take the gap to `hr-talent-lead`. When a scope moves, this map moves in the
same commit.

## Security & Compliance

| Capability | Owner | Doctrine & gate |
|---|---|---|
| Authentication & authorization design (ABAC/RBAC) | `security-architect` | `skills/app-hardening/SKILL.md` rules 7, 11, 15–17 |
| AuthZ enforcement in code (server + RLS) | `backend-engineer` (`database-architect` for policies) | `skills/supabase-craft/SKILL.md`; gate: `appsec-engineer` |
| Data encryption — in transit | `network-engineer` (requirements: `security-architect`) | TLS/mTLS doctrine in its scope |
| Data encryption — at rest + key custody | `security-architect` (`cloud-infra-engineer` provisions) | `skills/production-readiness/SKILL.md` rule 6 |
| Secrets management & rotation | `devsecops-engineer` (design requirements: `security-architect`) | `skills/agentic-security/SKILL.md` response protocol |
| Vulnerability review (OWASP, deps) | `appsec-engineer` | pre-ship gate, `skills/app-hardening/SKILL.md` |
| Adversarial validation of own defenses | `security-pentester` | findings report, defensive only |
| Compliance standards by name (GDPR, UAE PDPL, SOC 2; HIPAA/PCI-DSS awareness) | `compliance-privacy-engineer` | `skills/production-readiness/SKILL.md` rule 7, advisory register |
| Privacy engineering (PII, retention, consent) | `compliance-privacy-engineer` | data-handling spec; legal items L1–L2 in `skills/app-hardening/SKILL.md` |
| Pipeline & supply-chain security | `devsecops-engineer` | SAST/DAST/SCA gates in CI |
| Synthetic-twin / air-gapped-installation boundary & offline transfer | `security-architect` (`database-architect` state map, `backend-engineer` twin entrypoints) | `skills/securemax/SKILL.md`; gate: `appsec-engineer` consumes the acceptance record |
| Offline release signing, trust enrollment, rotation & revocation | `devsecops-engineer` (`devops-platform-engineer` builds the curated payload) | `skills/securemax/SKILL.md` rules 5–6 |
| Synthetic demo data generation (never renamed real records) | `data-engineer` (`compliance-privacy-engineer` rules on the register) | `skills/securemax/SKILL.md` rule 1 |

## Testing & Quality

| Capability | Owner | Doctrine & gate |
|---|---|---|
| Test strategy & CI quality-gate policy | `test-architect` | `skills/engineering-method/SKILL.md` (steward) |
| Unit / integration / E2E tests | `qa-automation-engineer` | RED gate, `skills/verification-protocol/SKILL.md` |
| Load & stress tests (non-functional targets) | `qa-automation-engineer` (`test-architect` sets the tier) | `skills/production-readiness/SKILL.md` rule 4 |
| Code review | `code-reviewer` | severity-ranked, read-only; every diff |
| Static analysis / linting | `devops-platform-engineer` (CI) | Verification Protocol gate 3; config guarded by hooks |
| Design review of user-facing changes | `design-reviewer` | `skills/design-excellence/SKILL.md` gate |
| Independent output judgment / retros | `self-eval-critic` | `skills/verification-protocol/SKILL.md` |

## Architecture & Data

| Capability | Owner | Doctrine & gate |
|---|---|---|
| System design, boundaries, ADRs | `principal-architect` | design before build; `/saeed:hire` phase 1 |
| API design & documentation | `api-designer` | contract-first OpenAPI/SDL; `skills/mcp-craft/SKILL.md` for tool surfaces |
| Database design & safe migrations | `database-architect` | expand/contract, `skills/supabase-craft/SKILL.md` |
| Query performance | `query-optimization-engineer` | measured before/after |
| Caching layers (app/edge, TTL + invalidation) | `backend-engineer` (`edge-serverless-engineer` at the edge) | `skills/production-readiness/SKILL.md` rule 5 |
| Rate limiting | `backend-engineer` (`api-designer` names the limit in the contract) | `skills/app-hardening/SKILL.md` rule 1; gate: `appsec-engineer` |
| Error handling & logging | `backend-engineer` | `skills/app-hardening/SKILL.md` rules 8, 10 |
| Realtime & event-driven features | `realtime-engineer` | delivery/ordering guarantees in scope |
| Data pipelines / ETL | `data-engineer` | provenance-tagged ingestion, `skills/orchestration-protocol/SKILL.md` |

## Infrastructure & Operations

| Capability | Owner | Doctrine & gate |
|---|---|---|
| Cloud infrastructure as code | `cloud-infra-engineer` | no manual prod changes; least privilege |
| Networking, load balancing, DNS/TLS design | `network-engineer` | specs handed to `cloud-infra-engineer` to provision |
| Containerization / Docker / GPU substrate | `ai-systems-engineer` | hardened, pinned, non-root images |
| Monitoring & observability (SLOs, alerts, incidents) | `sre-observability-engineer` | instrument-first; runbooks per alert |
| Backups & disaster recovery (RPO/RTO, restore drills) | `sre-observability-engineer` (`database-architect`, `cloud-infra-engineer`) | `skills/production-readiness/SKILL.md` rules 1–2 — the gate |
| Scaling & capacity (load-proven, vertical-first) | `sre-observability-engineer` (`cloud-infra-engineer` provisions) | `skills/production-readiness/SKILL.md` rule 4 |
| Wire/data/hosting performance | `frontend-performance-engineer` (gate) | `skills/performance-discipline/SKILL.md` |

## DevOps & Deployment

| Capability | Owner | Doctrine & gate |
|---|---|---|
| CI/CD pipelines & release automation | `devops-platform-engineer` | reversible deploys; gates before deploy |
| Environment management (dev/staging/prod, per-env secrets) | `devops-platform-engineer` | `skills/production-readiness/SKILL.md` rule 3 |
| Branch integration & merge discipline | `devops-platform-engineer` | `skills/orchestration-protocol/SKILL.md` |
| Edge/serverless delivery | `edge-serverless-engineer` | cold-start & caching discipline |
| Model serving & inference ops | `mlops-engineer` | air-gapped vLLM stack in scope |

## Product Surfaces

| Capability | Owner | Doctrine & gate |
|---|---|---|
| Web frontend | `frontend-engineer` | `skills/design-excellence/SKILL.md`; gate: `design-reviewer` |
| Native iOS / Android / macOS | `ios-engineer` / `android-engineer` / `macos-engineer` | platform-native depth, bilingual RTL |
| Cross-platform mobile | `react-native-engineer` | offline-first sync |
| PWA / offline web | `pwa-offline-engineer` | service-worker caching per resource |
| Lottie animations (edit, retheme, retime, optimize, convert, embed, playback) | `lottie-engineer` | `skills/design-excellence/SKILL.md` motion laws; gate: `design-reviewer` |
| Design system & tokens | `design-systems-engineer` | house tokens, RTL variants |
| UX, research, visual craft | `product-designer` (`ux-researcher`, `ui-visual-designer`) | `skills/design-excellence/SKILL.md` |
| Accessibility (WCAG 2.2 AA) | `accessibility-specialist` | advisory + fixes on every UI surface |
| Internationalization / Arabic RTL | `i18n-localization-engineer` (`nlp-bilingual-specialist` for NLP) | bilingual mandate, house-wide |
| Documentation (READMEs, runbooks, API docs) | `technical-writer` | bilingual where user-facing |
| Attribution & brand-string integrity (EN + AR credit lines) | `technical-writer` (`i18n-localization-engineer` for the Arabic string; `the-boss` gates it at sign-off) | `skills/attribution/SKILL.md`; `hooks/guard-attribution-canon.sh` at write time, validator check 14 in CI |

## AI & Retrieval

| Capability | Owner | Doctrine & gate |
|---|---|---|
| LLM application work (Anthropic API, agents, evals) | `llm-engineer` | evals before ship |
| RAG design end to end | `rag-architect` | retrieval/answer evals, ABAC-filtered |
| Embeddings & vector search | `vector-search-engineer` | hybrid retrieval, index tuning |
| Classical/deep ML | `ml-engineer` | rigorous splits & metrics |
| Bilingual NLP (Arabic/English) | `nlp-bilingual-specialist` | dialect/MSA, normalization |

## Delivery & Governance

| Capability | Owner | Doctrine & gate |
|---|---|---|
| Requirements → buildable specs | `product-engineer` | `skills/spec-quality/SKILL.md` |
| Orchestration & routing | `team-orchestrator` | `skills/orchestration-protocol/SKILL.md` |
| Accountability & Definition of Done | `the-boss` | consumes every gate verdict above |
| Continuous improvement & convergence | `continuous-improvement-lead` | `skills/continuous-improvement/SKILL.md` |
| Team staffing (hires, redundancy) | `hr-talent-lead` | role briefs to `roster-maintainer` |
| Roster composition | `roster-maintainer` | disjoint scopes, reciprocal handoffs |
| Agent prompt quality | `agent-optimizer` | `skills/canon-craft/SKILL.md` for canons |
| Inter-agent formats & prompt craft | `prompt-engineer` | shared brief/ticket templates |
| Model currency | `model-scout` | `.saeed/models.md`, verified availability |
| Self-governance without a lead | `self-eval-critic` (conscience) + doctrine | `skills/self-governance/SKILL.md` |
