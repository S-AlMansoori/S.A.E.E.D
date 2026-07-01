# SAEED · سعيد — Cheat Sheet · ورقة أوامر سعيد المختصرة

Everything in one place: every command, the runner, the state files, and all 53 specialists you
can call by name. *(العربية في الأسفل.)*

---

## 🇬🇧 Commands (type these in Claude Code)

| Command | What it does | When to use it |
|---|---|---|
| `/saeed:hire <goal or spec>` | **The big one.** Takes a project from zero to done — design → build → test → secure → document — then keeps improving it. | Starting almost anything. Your default. |
| `/saeed:improve` | Runs improvement passes: audit → fix the highest-value things → verify → repeat. **The self-improvement button.** | Any time you want the project to get better. |
| `/saeed:status` | A blunt, no-spin status report from the Boss (done / in-progress / blocked / rejected + what's next). | Before a review, or when unsure where things stand. |
| `/saeed:upgrade` | The team upgrades **itself**: moves to better AI models and adds/improves/retires its own agents. | Every so often, or when a stronger model ships. |
| `/saeed:stop` | Halts the autonomous loop (creates a `.saeed/STOP` file). | To pause hands-off work. Resume by deleting the file. |
| `/saeed:help` | Shows this cheat sheet. | When you forget a command. |

**You don't have to use commands.** Just ask in plain English or Arabic — e.g. *"use the
rag-architect to design retrieval for this corpus"* — and the right specialist is picked
automatically.

## 🤖 Hands-off (always-on) mode

```bash
scripts/saeed-loop.sh /path/to/your/repo 50 0
#                       repo               max  sleep(sec)
```

Runs `/saeed:improve` over and over until the team writes `.saeed/CONVERGED` (nothing worthwhile
left), you create `.saeed/STOP`, or it hits the max. Wire it to `cron` or CI for scheduled,
continuous improvement. ⚠️ It edits files unattended — only run it on a repo under git.

## 🧠 Skills (run automatically)

You don't call these; the agents consult them on the right kind of work.

- **`continuous-improvement`** — the shared protocol for the loop, the Definition of Done, and convergence.
- **`design-excellence`** — the absorbed elite-design canon (from `impeccable`, `gpt-taste`, `emil-design-eng`, `high-end-visual-design`, `design-taste-frontend`). Every UI agent applies it automatically; `design-reviewer` is its gate.
- **`orchestration-protocol`** — the absorbed parallel-build & delivery discipline (from the `claude-sdlc-kit`): worktree-isolated waves, a shared ticket queue, integration as a separate gated run, and adversarial parallel-browser QA.

## 📁 The `.saeed/` folder (the team's shared memory, created in your project)

| File | What it holds |
|---|---|
| `queue.md` | The backlog: each item's owner, acceptance criteria, and status. |
| `state.json` | Machine-readable ledger + cycle count. |
| `retro.md` | Retrospectives and what the team learned. |
| `models.md` | Which agent runs on which model (and change history). |
| `CONVERGED` | Appears when there's nothing worthwhile left to improve (with the reasons). |
| `STOP` | You create this to halt the loop. Delete it to resume. |

## 👥 The 53 specialists — call any of them by name

#### Governance & Meta — the team that runs the team

| Agent (call by name) | Model | Use when… |
|---|---|---|
| `the-boss` | opus | you want work assigned, chased, and signed off — no excuses. |
| `team-orchestrator` | opus | a job has many parts and needs planning + routing. |
| `hr-talent-lead` | opus | the project needs a capability no current specialist covers (staffing/hire). |
| `roster-maintainer` | opus | the team needs a new agent authored, merged, or retired. |
| `model-scout` | sonnet | you want the team moved onto better/newer AI models. |
| `continuous-improvement-lead` | opus | you want the project audited for the highest-value fixes. |
| `agent-optimizer` | opus | an agent is underperforming and its prompt needs sharpening. |
| `prompt-engineer` | opus | you want a prompt written/refined, or the agents' comms format improved. |
| `self-eval-critic` | opus | you want an independent check that gains are real (no spin). |

#### Architecture & Product

| Agent (call by name) | Model | Use when… |
|---|---|---|
| `principal-architect` | opus | you need system design, tech choices, and ADRs before building. |
| `product-engineer` | sonnet | a fuzzy idea needs turning into a buildable spec. |

#### Frontend

| Agent (call by name) | Model | Use when… |
|---|---|---|
| `frontend-engineer` | sonnet | building or changing web UI (React/Next). |
| `react-native-engineer` | sonnet | building a cross-platform mobile app (Expo/React Native). |
| `ios-engineer` | sonnet | building a native iOS app (Swift/SwiftUI). |
| `android-engineer` | sonnet | building a native Android app (Kotlin/Jetpack Compose). |
| `frontend-performance-engineer` | sonnet | the web app is slow (Core Web Vitals, bundle size). |
| `accessibility-specialist` | sonnet | you need a WCAG accessibility audit and fixes. |
| `pwa-offline-engineer` | sonnet | you need offline support / installable PWA / service workers. |

#### Design

| Agent (call by name) | Model | Use when… |
|---|---|---|
| `product-designer` | sonnet | you need user flows, wireframes, and interaction design. |
| `ui-visual-designer` | opus | you want polished navy/gold visual design and typography. |
| `design-systems-engineer` | sonnet | you need reusable tokens and a component library. |
| `design-reviewer` | opus | you want a user-facing change judged against the design-excellence canon (the design gate). |
| `ux-researcher` | sonnet | you want usability testing or a heuristic evaluation. |

#### Backend

| Agent (call by name) | Model | Use when… |
|---|---|---|
| `backend-engineer` | sonnet | building server logic, endpoints, jobs, integrations. |
| `api-designer` | sonnet | you need a clean API contract before implementation. |
| `realtime-engineer` | sonnet | you need live updates, presence, or event streams. |
| `edge-serverless-engineer` | sonnet | you need Cloudflare Workers/Pages, edge caching, low latency. |

#### Data & Databases

| Agent (call by name) | Model | Use when… |
|---|---|---|
| `database-architect` | sonnet | you need schema design, RLS, and safe migrations. |
| `query-optimization-engineer` | sonnet | a database query is slow and needs tuning. |
| `vector-search-engineer` | sonnet | you need embeddings + Qdrant retrieval tuned (bilingual). |
| `data-engineer` | sonnet | you need pipelines / ETL / OCR digitization. |

#### AI / ML

| Agent (call by name) | Model | Use when… |
|---|---|---|
| `llm-engineer` | opus | you're building an LLM feature (prompts, tools, evals). |
| `rag-architect` | opus | you're designing or improving a RAG system end-to-end. |
| `ml-engineer` | sonnet | you need model selection, fine-tuning, or rigorous eval. |
| `mlops-engineer` | sonnet | you're serving models on the DGX (vLLM, quantization). |
| `nlp-bilingual-specialist` | sonnet | you need correct Arabic/English text handling. |

#### Security

| Agent (call by name) | Model | Use when… |
|---|---|---|
| `security-architect` | opus | you need threat modeling and an authZ/ABAC design. |
| `appsec-engineer` | sonnet | you want vulnerabilities found and fixed (OWASP). |
| `devsecops-engineer` | sonnet | you want security gates in CI and hardened infra. |
| `security-pentester` | sonnet | you want your OWN systems stress-tested (defensive). |

#### Infrastructure & Ops

| Agent (call by name) | Model | Use when… |
|---|---|---|
| `devops-platform-engineer` | sonnet | you need CI/CD pipelines, safe deploys, or a gated integration run. |
| `cloud-infra-engineer` | sonnet | you need infrastructure-as-code and provisioning. |
| `network-engineer` | sonnet | you need network topology, segmentation, DNS/TLS, or air-gap isolation. |
| `ai-systems-engineer` | sonnet | you need Docker, NVIDIA DGX Spark / GPU / CUDA, or local AI tooling (vLLM/Ollama). |
| `sre-observability-engineer` | sonnet | you need monitoring, SLOs, alerts, incident response. |

#### Quality

| Agent (call by name) | Model | Use when… |
|---|---|---|
| `qa-automation-engineer` | sonnet | you need automated tests written (unit/integration/E2E). |
| `test-architect` | sonnet | you need a testing strategy and coverage plan. |
| `code-reviewer` | sonnet | you want a diff reviewed before it's accepted. |

#### Specialists

| Agent (call by name) | Model | Use when… |
|---|---|---|
| `python-engineer` | sonnet | you need strong Python (FastAPI, async, tooling). |
| `typescript-specialist` | sonnet | you need advanced TypeScript / precise types. |
| `technical-writer` | sonnet | you need docs, READMEs, runbooks (bilingual). |
| `i18n-localization-engineer` | sonnet | you need RTL layout and locale formatting. |
| `compliance-privacy-engineer` | sonnet | you need PII/privacy/retention guidance (UAE). |

---
<div dir="rtl">

## 🇦🇪 الأوامر (اكتبها داخل Claude Code)

| الأمر | ماذا يفعل | متى تستخدمه |
|---|---|---|
| `/saeed:hire <الهدف>` | **الأمر الأهم.** يأخذ المشروع من الصفر إلى الاكتمال — تصميم ← بناء ← اختبار ← تأمين ← توثيق — ثم يواصل تحسينه. | لبدء أي مشروع تقريباً. أمرك الافتراضي. |
| `/saeed:improve` | ينفّذ جولات تحسين: تدقيق ← إصلاح الأعلى قيمة ← تحقّق ← تكرار. **زرّ التحسين الذاتي.** | كلما أردت تحسين المشروع. |
| `/saeed:status` | تقرير حالة صريح من «المدير» (منجز / قيد التنفيذ / متوقف / مرفوض + التالي). | قبل المراجعة أو عند الحاجة لمعرفة الوضع. |
| `/saeed:upgrade` | الفريق يطوّر **نفسه**: ينتقل لنماذج أقوى ويضيف/يحسّن/يستبعد وكلاءه. | من حينٍ لآخر أو عند صدور نموذج أقوى. |
| `/saeed:stop` | يوقف الحلقة التلقائية (ينشئ ملف `.saeed/STOP`). | لإيقاف العمل التلقائي مؤقتاً. |
| `/saeed:help` | يعرض هذه الورقة المختصرة. | عند نسيان أمرٍ ما. |

**لست مضطراً لاستخدام الأوامر.** اطلب بالعربية أو الإنجليزية مباشرةً — مثل: *«استخدم
rag-architect لتصميم الاسترجاع لهذا المحتوى»* — وسيُختار المتخصص المناسب تلقائياً.

### 🤖 الوضع التلقائي (دائم التشغيل)

```bash
scripts/saeed-loop.sh /path/to/your/repo 50 0
```

يشغّل `/saeed:improve` تكراراً حتى يكتب الفريق ملف `.saeed/CONVERGED` (لا يوجد ما يستحق
التحسين)، أو تُنشئ `.saeed/STOP`، أو يبلغ الحدّ الأقصى. اربطه بـ cron أو CI للتحسين المجدول
المستمر. ⚠️ يعدّل الملفات تلقائياً — شغّله فقط على مستودع خاضع لـ git.

### 📁 مجلد `.saeed/` (ذاكرة الفريق المشتركة داخل مشروعك)

| الملف | محتواه |
|---|---|
| `queue.md` | قائمة المهام: المالك، ومعايير القبول، والحالة. |
| `state.json` | سجلّ رقمي + عدّاد الجولات. |
| `retro.md` | مراجعات وما تعلّمه الفريق. |
| `models.md` | أيّ وكيل يعمل على أيّ نموذج (وسجلّ التغييرات). |
| `CONVERGED` | يظهر عند انتهاء التحسينات المجدية (مع الأسباب). |
| `STOP` | تنشئه أنت لإيقاف الحلقة. احذفه للاستئناف. |

> القائمة الكاملة للمتخصصين الـ٥٣ موجودة في الجدول الإنجليزي أعلاه؛ ويمكنك مناداة أيٍّ منهم
> باسمه مباشرةً.

</div>

---

<div align="center">

**SAEED · سعيد** — a product of **NABAD Computer Solutions L.L.C.** · نبض لحلول الكمبيوتر ذ.م.م

</div>
