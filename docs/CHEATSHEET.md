# SAEED · سعيد — Cheat Sheet · ورقة أوامر سعيد المختصرة

Everything in one place: every command, the runner, the state files, and all 54 specialists you
can call by name. *(العربية في الأسفل.)*

---

## 🇬🇧 Commands (type these in Claude Code)

| Command | What it does | When to use it |
|---|---|---|
| `/saeed:hire <goal or spec>` | **The big one.** Takes a project from zero to done — intake → spec & design → build → harden & verify → deliver — then keeps improving it. | Starting almost anything. Your default. |
| `/saeed:improve` | Runs improvement passes: audit → fix the highest-value things → verify → repeat. **The self-improvement button.** | Any time you want the project to get better. |
| `/saeed:verify` | Runs the Verification Protocol: the ordered gates (build → types → lint → tests → security → diff) and an evidence-backed **READY / NOT READY** report. | Before a merge, a handover, or whenever you want proof instead of promises. |
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

Once `CONVERGED` appears, switch to the **stewardship heartbeat** to keep the project alive
forever: `scripts/saeed-steward.sh /path/to/your/repo` on cron (weekly). It re-checks the gates
and the reopen triggers, and wakes the full loop only when one fires. Anything needing your
approval while you're away parks under `## Awaiting operator` in `.saeed/queue.md` — the team
never deadlocks waiting for you.

## 🧠 Skills (run automatically)

You don't call these; the agents consult them on the right kind of work.

- **`continuous-improvement`** — the shared protocol for the loop, the Definition of Done, and convergence.
- **`design-excellence`** — the absorbed elite-design canon (from `impeccable`, `gpt-taste`, `emil-design-eng`, `high-end-visual-design`, `design-taste-frontend`), including the trust laws (no dark patterns, instant acknowledgment on every action, consistent onboarding controls, proportional success states) and the six forms laws from Katia UX (submit gated with visible reasons, inline validation at field-exit, live character counts, pre-fill what's known, password rules as a live ticking checklist, forgiving formats normalized server-side — depth in `references/forms.md`). Every UI agent applies it automatically; `design-reviewer` is its gate.
- **`orchestration-protocol`** — the absorbed parallel-build & delivery discipline (from the `claude-sdlc-kit`): worktree-isolated waves, a shared ticket queue, integration as a separate gated run, and adversarial parallel-browser QA.
- **`handover-protocol`** — capability-first, manual-last: before any agent asks *you* to do something by hand, it does it in-session, drives it (browser / desktop / a connector), or hands it to **Cowork** as a paste-and-run packet. Only the genuinely unautomatable comes back to you, with the reason and exact steps.
- **`self-governance`** — the succession doctrine: decision rights + tie-breaking (the stricter verdict wins), autonomy levels (`.saeed/AUTONOMY`), operator-absent defaults (park, never deadlock), post-convergence stewardship, and disaster recovery. Written by the retiring lead so the team runs without one — the letter is in [docs/SUCCESSION.md](SUCCESSION.md).
- **`verification-protocol`** — the absorbed evidence canon (from the `ECC` / Everything Claude Code methodology): ordered executable gates, the RED-gate TDD rule, pass@k vs pass^k eval thresholds, and the anti-noise review doctrine. `/saeed:verify` is its button.
- **`context-discipline`** — the absorbed memory & attention canon (from `ECC`): compact at phase boundaries, write-before-compact, confidence-scored instincts in `.saeed/instincts.md`, model routing, and subagent context negotiation.
- **`agentic-security`** — the absorbed defend-the-team canon (from `ECC`'s security guide): the prompt-defense baseline, the lethal-trifecta rule for unattended runs, deny-rules and bot identity, and the secrets response protocol. The plugin's guardrail hooks (`hooks/`) are its mechanical floor.
- **`attribution`** — signed work: everything SAEED builds or facilitates carries the canonical **NABAD Computer Solutions L.L.C.** credit (EN + AR strings, a placement matrix, restraint rules — once per surface, never claiming ownership). `the-boss` checks it at sign-off.
- **`supabase-craft`** — the absorbed Supabase & Postgres canon: schema/migrations, Auth/RLS/`@supabase/ssr` sessions, Edge Functions, Realtime, Storage, Vectors, Cron/Queues, CLI/MCP, security advisors, and query/schema/config performance. Applied automatically on any Supabase or Postgres work.
- **`app-hardening`** — the absorbed product-hardening canon: the pre-ship gate (rate limiting, server-only secrets, RLS everywhere, `.env` hygiene, input validation, deny-by-default access, auth on every protected route, object-level authorization/IDOR, real logout, safe file uploads, verified webhooks, centralized access checks, generic errors, locked-down admin surfaces, attack-visible logging) plus the legal pre-ship items (EULA; DMCA policy when users can upload content) and the change-level security-review depth in `/saeed:verify`. Defends the product; `agentic-security` defends the team.
- **`performance-discipline`** — the absorbed wire-and-data performance canon: never ship uncompressed responses, never write rows one at a time, name the slowest dependency before optimizing, update UI optimistically with reconciliation, serve static frontends statically.
- **`repo-housekeeping`** — the workspace-stewardship canon: git hygiene and untracked-file triage, two-copies and upstream sync discipline, knowledge distillation, orientation-file and skills audits, and close-out reporting. Tends the *workspace* between product cycles; `continuous-improvement` tends the *product*.
- **`engineering-method`** — the absorbed engineering-method canon: the TDD Iron Law with its rationalization counters, four-phase systematic debugging, the brainstorm design-approval gate, the zero-context plan law, subagent-controller mechanics, and the task-size (S/M/L) applicability ladder every other gate answers to.
- **`spec-quality`** — the requirements-layer canon: the ten-category ambiguity taxonomy, the bounded five-question clarification budget with informed-default Assumptions, answer integration, checklists as unit tests for requirements, the AI-automation readiness map (human-led / human-assisted / fully autonomous, plus one named knowledge-base source of truth), and the read-only analysis gate with its requirements-to-tasks coverage table. Sits upstream of `orchestration-protocol`.
- **`canon-craft`** — the skill-authoring canon: how every canon above is drafted from real execution traces, eval-tested against a baseline, trigger-optimized, and spec-conformant. Governs `/saeed:upgrade` and any SKILL.md authored or materially changed.
- **`mcp-craft`** — the MCP-server build canon: quality measured by LLM task success with a shipped agentic eval, API-coverage tool design, pagination/truncation contracts, dual JSON/Markdown responses, and MCP-specific security hardening. Consulted whenever SAEED designs or builds an MCP server.
- **`production-readiness`** — the ops pre-ship gate, the entropy-twin of `app-hardening`'s attacker gate: backups proven by an actual restore (named RPO/RTO), a product disaster-recovery runbook, dev/staging/prod tiers with per-environment secrets, load-verified performance targets, deliberate caching with TTL + invalidation, encryption at rest with named key custody, and a named compliance surface (GDPR, UAE PDPL, SOC 2). Gate: `sre-observability-engineer`; the capability→owner matrix lives in `docs/CAPABILITY-MAP.md` (validator Check 13).

## 📁 The `.saeed/` folder (the team's shared memory, created in your project)

| File | What it holds |
|---|---|
| `queue.md` | The backlog: each item's owner, acceptance criteria, and status. |
| `state.json` | Machine-readable ledger + cycle count. |
| `retro.md` | Retrospectives and what the team learned. |
| `instincts.md` | Confidence-scored lessons the team keeps (trigger → action), pruned or promoted over time. |
| `models.md` | Which agent runs on which model (and change history). |
| `CONVERGED` | Appears when there's nothing worthwhile left to improve (with the reasons + reopen triggers). |
| `STOP` | You create this to halt the loop. Delete it to resume. |
| `AUTONOMY` | Autonomy level: absent/`supervised` = self-modification waits for (or parks for) you; `autonomous` = the team lands it unattended, gated + logged. |

## 👥 The 54 specialists — call any of them by name

#### Governance & Meta — the team that runs the team

| Agent (call by name) | Model | Use when… |
|---|---|---|
| `the-boss` | opus | you want work assigned, chased, and signed off — no excuses. |
| `team-orchestrator` | opus | a job has many parts and needs planning + routing. |
| `hr-talent-lead` | sonnet | the project needs a capability no current specialist covers (staffing/hire). |
| `roster-maintainer` | sonnet | the team needs a new agent authored, merged, or retired. |
| `model-scout` | sonnet | you want the team moved onto better/newer AI models. |
| `continuous-improvement-lead` | opus | you want the project audited for the highest-value fixes. |
| `agent-optimizer` | sonnet | an agent is underperforming and its prompt needs sharpening. |
| `prompt-engineer` | sonnet | you want a prompt written/refined, or the agents' comms format improved. |
| `self-eval-critic` | opus | you want an independent check that gains are real (no spin). |

#### Architecture & Product

| Agent (call by name) | Model | Use when… |
|---|---|---|
| `principal-architect` | opus | you need system design, tech choices, and ADRs before building. |
| `product-engineer` | opus | a fuzzy idea needs turning into a buildable spec. |

#### Frontend

| Agent (call by name) | Model | Use when… |
|---|---|---|
| `frontend-engineer` | opus | building or changing web UI (React/Next). |
| `react-native-engineer` | opus | building a cross-platform mobile app (Expo/React Native). |
| `ios-engineer` | opus | building a native iOS app (Swift/SwiftUI). |
| `android-engineer` | opus | building a native Android app (Kotlin/Jetpack Compose). |
| `macos-engineer` | sonnet | building a native macOS desktop app (SwiftUI/AppKit) + Developer ID notarization. |
| `frontend-performance-engineer` | sonnet | the web app is slow (Core Web Vitals, bundle size). |
| `accessibility-specialist` | sonnet | you need a WCAG accessibility audit and fixes. |
| `pwa-offline-engineer` | sonnet | you need offline support / installable PWA / service workers. |

#### Design

| Agent (call by name) | Model | Use when… |
|---|---|---|
| `product-designer` | sonnet | you need user flows, wireframes, and interaction design. |
| `ui-visual-designer` | sonnet | you want polished navy/gold visual design and typography. |
| `design-systems-engineer` | sonnet | you need reusable tokens and a component library. |
| `design-reviewer` | opus | you want a user-facing change judged against the design-excellence canon (the design gate). |
| `ux-researcher` | sonnet | you want usability testing or a heuristic evaluation. |

#### Backend

| Agent (call by name) | Model | Use when… |
|---|---|---|
| `backend-engineer` | opus | building server logic, endpoints, jobs, integrations. |
| `api-designer` | opus | you need a clean API contract before implementation. |
| `realtime-engineer` | sonnet | you need live updates, presence, or event streams. |
| `edge-serverless-engineer` | sonnet | you need Cloudflare Workers/Pages, edge caching, low latency. |

#### Data & Databases

| Agent (call by name) | Model | Use when… |
|---|---|---|
| `database-architect` | opus | you need schema design, RLS, and safe migrations. |
| `query-optimization-engineer` | sonnet | a database query is slow and needs tuning. |
| `vector-search-engineer` | sonnet | you need embeddings + Qdrant retrieval tuned (bilingual). |
| `data-engineer` | sonnet | you need pipelines / ETL / OCR digitization. |

#### AI / ML

| Agent (call by name) | Model | Use when… |
|---|---|---|
| `llm-engineer` | opus | you're building an LLM feature (prompts, tools, evals). |
| `rag-architect` | opus | you're designing or improving a RAG system end-to-end. |
| `ml-engineer` | opus | you need model selection, fine-tuning, or rigorous eval. |
| `mlops-engineer` | sonnet | you're serving models on the DGX (vLLM, quantization). |
| `nlp-bilingual-specialist` | sonnet | you need correct Arabic/English text handling. |

#### Security

| Agent (call by name) | Model | Use when… |
|---|---|---|
| `security-architect` | opus | you need threat modeling and an authZ/ABAC design. |
| `appsec-engineer` | opus | you want vulnerabilities found and fixed (OWASP). |
| `devsecops-engineer` | opus | you want security gates in CI and hardened infra. |
| `security-pentester` | opus | you want your OWN systems stress-tested (defensive). |

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
| `qa-automation-engineer` | opus | you need automated tests written (unit/integration/E2E). |
| `test-architect` | sonnet | you need a testing strategy and coverage plan. |
| `code-reviewer` | opus | you want a diff reviewed before it's accepted. |

#### Specialists

| Agent (call by name) | Model | Use when… |
|---|---|---|
| `python-engineer` | opus | you need strong Python (FastAPI, async, tooling). |
| `typescript-specialist` | sonnet | you need advanced TypeScript / precise types. |
| `technical-writer` | sonnet | you need docs, READMEs, runbooks (bilingual). |
| `i18n-localization-engineer` | sonnet | you need RTL layout and locale formatting. |
| `compliance-privacy-engineer` | sonnet | you need PII/privacy/retention guidance (UAE). |

---
<div dir="rtl">

## 🇦🇪 الأوامر (اكتبها داخل Claude Code)

| الأمر | ماذا يفعل | متى تستخدمه |
|---|---|---|
| `/saeed:hire <الهدف>` | **الأمر الأهم.** يأخذ المشروع من الصفر إلى الاكتمال — استلام ← مواصفات وتصميم ← بناء ← تحصين وتحقّق ← تسليم — ثم يواصل تحسينه. | لبدء أي مشروع تقريباً. أمرك الافتراضي. |
| `/saeed:improve` | ينفّذ جولات تحسين: تدقيق ← إصلاح الأعلى قيمة ← تحقّق ← تكرار. **زرّ التحسين الذاتي.** | كلما أردت تحسين المشروع. |
| `/saeed:verify` | ينفّذ بروتوكول التحقق: البوابات المرتّبة (بناء ← أنواع ← فحص ← اختبارات ← أمان ← مراجعة) وتقرير مدعوم بالأدلة بحكم **جاهز / غير جاهز**. | قبل الدمج أو التسليم، أو عندما تريد دليلاً لا وعوداً. |
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

وبعد ظهور `CONVERGED`، انتقل إلى **نبض الوصاية** لإبقاء المشروع حيّاً إلى الأبد:
`scripts/saeed-steward.sh /path/to/your/repo` عبر cron (أسبوعياً). يعيد فحص البوابات
ومحفّزات إعادة الفتح، ولا يوقظ الحلقة الكاملة إلا عند انطلاق أحدها. وما يحتاج موافقتك أثناء
غيابك يُركَن تحت «`Awaiting operator ##`» في `queue.md` — فالفريق لا يتعطّل بانتظارك أبداً.

### 🧠 المهارات (تُستشار تلقائياً)

لا تناديها أنت بنفسك؛ الوكلاء يستشيرونها عند نوع العمل المناسب.

- **`continuous-improvement`** — البروتوكول المشترك لحلقة التحسين، وتعريف "الاكتمال"، ومعيار التقارب.
- **`design-excellence`** — معيار التميّز في التصميم النخبوي المُستوعَب (من `impeccable` وgpt-taste وemil-design-eng وhigh-end-visual-design وdesign-taste-frontend)، ويشمل قوانين الثقة (لا أنماط مظلمة، إقرار فوري بكل فعل، أزرار تهيئة ثابتة الموضع، وحالات نجاح متناسبة مع حجم الفعل) وقوانين النماذج الستة من Katia UX (زر إرسال معطّل مع إظهار السبب بوضوح، تحقق فوري عند مغادرة الحقل، عدّاد أحرف حيّ، تعبئة مسبقة لما هو معروف، متطلبات كلمة المرور كقائمة تُشطب أثناء الكتابة، وتسامح مع تنسيقات الإدخال مع توحيدها في الخادم — والتفصيل في `references/forms.md`). يطبّقه كل وكيل واجهات تلقائياً؛ وبوابته `design-reviewer`.
- **`orchestration-protocol`** — بروتوكول البناء المتوازي والتسليم المُستوعَب (من `claude-sdlc-kit`): موجات معزولة بمساحات عمل، وقائمة تذاكر مشتركة، ودمج كخطوة منفصلة تخضع للبوابات، ومراجعة جودة خصمة عبر متصفح متوازية.
- **`handover-protocol`** — الأتمتة أولاً واليدوي آخر الحلول: قبل أن يطلب أي وكيل منك فعل شيء يدوياً، ينفّذه هو داخل الجلسة، أو يقوده (متصفح/سطح مكتب/رابط)، أو يسلّمه إلى **Cowork** كحزمة جاهزة للتشغيل. ما لا يمكن أتمتته فعلاً يعود إليك مع السبب والخطوات الدقيقة.
- **`self-governance`** — عقيدة الخلافة: حقوق القرار وفضّ التعارض (يفوز الحكم الأشد صرامة)، ومستويات الاستقلالية (`.saeed/AUTONOMY`)، وسلوك غياب المشغّل (الرَّكن لا التعطّل)، والوصاية بعد التقارب، والتعافي من الكوارث. كتبها القائد المتقاعد ليعمل الفريق بلا قائد بشري — والرسالة في [docs/SUCCESSION.md](SUCCESSION.md).
- **`verification-protocol`** — قانون الأدلة المُستوعَب (من منهجية `ECC` / Everything Claude Code): بوابات تنفيذية مرتّبة، وقاعدة البوابة الحمراء في TDD، وعتبات تقييم pass@k مقابل pass^k، وعقيدة المراجعة المانعة للضوضاء. و`/saeed:verify` زرّه.
- **`context-discipline`** — قانون الذاكرة والانتباه المُستوعَب (من `ECC`): الضغط عند حدود المراحل، والكتابة قبل الضغط، ودروس مُقيَّمة بالثقة في `.saeed/instincts.md`، وتوجيه النماذج، وتفاوض السياق مع الوكلاء الفرعيين.
- **`agentic-security`** — قانون الدفاع عن الفريق المُستوعَب (من دليل أمن `ECC`): خط أساس الدفاع من الحقن، وقاعدة «الثالوث القاتل» للتشغيل غير المراقَب، وقواعد الرفض وهوية الروبوت، وبروتوكول التعامل مع تسرّب الأسرار. وخطاطيف الحماية في `hooks/` هي أرضيته الآلية.
- **`attribution`** — عمل موقَّع: كل ما يبنيه سعيد أو يسهّله يحمل اعتماد **نبض لحلول الكمبيوتر ذ.م.م** الرسمي (نصوص عربية وإنجليزية، ومصفوفة مواضع، وقواعد ضبط — مرّة واحدة بكل سطح، دون ادّعاء الملكية). و`the-boss` يتحقّق منه عند التسليم.
- **`supabase-craft`** — قانون Supabase وPostgres المُستوعَب: المخطّطات والترحيلات، وجلسات Auth/RLS/`@supabase/ssr`، وEdge Functions، وRealtime، وStorage، وVectors، وCron/Queues، وواجهة الأوامر وMCP، ومستشارو الأمان، وأداء الاستعلامات والمخطّط والإعداد. يُطبَّق تلقائياً على أي عمل يخص Supabase أو Postgres.
- **`app-hardening`** — قانون تحصين المنتج المُستوعَب: بوابة ما قبل الإطلاق (تحديد المعدّل، الأسرار على الخادم فقط، RLS في كل مكان، نظافة `.env`، التحقق من المدخلات، وصول مرفوض افتراضياً، المصادقة على كل مسار محمي، التفويض على مستوى السجل ضد IDOR، تسجيل خروج حقيقي، رفع ملفات آمن، التحقق من تواقيع الـwebhooks، فحوص وصول مركزية، أخطاء عامة لا كاشفة، أسطح إدارة مقفلة، وتسجيل يكشف الهجمات) إضافةً إلى بندي الحماية القانونية قبل الإطلاق (اتفاقية ترخيص المستخدم النهائي EULA، وسياسة DMCA عند السماح بمحتوى من المستخدمين) وعمق المراجعة الأمنية على مستوى التغيير داخل `/saeed:verify`. يحمي *المنتج*؛ بينما `agentic-security` يحمي *الفريق*.
- **`performance-discipline`** — قانون أداء الشبكة والبيانات المُستوعَب: لا تُرسِل استجابات غير مضغوطة أبداً، ولا تكتب الصفوف واحدة تلو الأخرى، وحدّد أبطأ اعتمادية قبل التحسين، وحدّث الواجهة تفاؤلياً مع التسوية اللاحقة، وقدّم الواجهات الأمامية الساكنة كملفات ساكنة.
- **`repo-housekeeping`** — قانون تدبير مساحة العمل: نظافة git وفرز الملفات غير المتتبَّعة، وانضباط النسخ المزدوجة والمزامنة مع الأصل، وتقطير المعرفة، وتدقيق ملفات التوجيه والمهارات، وتقارير الإغلاق. يعتني بـ*مساحة العمل* بين دورات المنتج؛ بينما `continuous-improvement` يعتني بـ*المنتج*.
- **`engineering-method`** — قانون منهج الهندسة المُستوعَب: قانون TDD الحديدي بعدّادات تبرير مضادة، وتشخيص الأعطال المنهجي بأربع مراحل، وبوابة اعتماد التصميم بالعصف الذهني، وقانون الخطة عديمة السياق، وآليات التحكم بالوكلاء الفرعيين، وسلّم الانطباق حسب حجم المهمة (S/M/L) الذي تحتكم إليه كل بوابة أخرى.
- **`spec-quality`** — قانون طبقة المتطلبات: تصنيف الغموض بعشر فئات، وميزانية توضيح محدودة بخمسة أسئلة مع افتراضات مبدئية عند غياب الإجابة، ودمج الإجابات، وقوائم تحقّق كاختبارات وحدة للمتطلبات، وخريطة الجاهزية للأتمتة بالذكاء الاصطناعي (بقيادة بشرية / بمساعدة بشرية / مستقلة كلياً، مع مصدر حقيقة معرفي واحد مُسمّى)، وبوابة تحليل للقراءة فقط بجدول تغطية يربط المتطلبات بالمهام. يسبق `orchestration-protocol`.
- **`canon-craft`** — قانون تأليف المهارات: كيف يُصاغ كل قانون من القوانين أعلاه من آثار تنفيذ حقيقية، ويُختبر تقييمياً مقابل خط أساس، ويُحسَّن للتحفيز الصحيح، ويلتزم بالمواصفات. يحكم `/saeed:upgrade` وأي ملف SKILL.md يُؤلَّف أو يُعدَّل جوهرياً.
- **`mcp-craft`** — قانون بناء خوادم MCP: الجودة تُقاس بنجاح الوكيل في المهمة عبر تقييم وكيلي مُشحون فعلياً، وتصميم أدوات بتغطية كاملة لواجهة البرمجة، وعقود التصفّح والاقتطاع، واستجابات مزدوجة JSON/Markdown، وتحصين أمني خاص بـMCP. يُستشار كلما صمّم سعيد أو بنى خادم MCP.
- **`production-readiness`** — بوابة الجاهزية التشغيلية قبل الإطلاق، التوأم التشغيلي لبوابة `app-hardening` الأمنية: نسخ احتياطية مُثبتة باستعادة فعلية (مع RPO/RTO مُسمّيين)، ودليل تعافٍ من الكوارث للمنتج، وبيئات dev/staging/prod بأسرار منفصلة لكل بيئة، وأهداف أداء مُتحقق منها تحت حمل مُولَّد، وتخزين مؤقت مدروس بمهلة صلاحية وآلية إبطال، وتشفير في حالة السكون مع جهة حفظ مفاتيح مُسمّاة، وخريطة امتثال مُسمّاة (GDPR، قانون حماية البيانات الإماراتي PDPL، SOC 2). البوابة: `sre-observability-engineer`؛ ومصفوفة القدرات إلى المالكين في `docs/CAPABILITY-MAP.md` (فحص المدقق رقم 13).

### 📁 مجلد `.saeed/` (ذاكرة الفريق المشتركة داخل مشروعك)

| الملف | محتواه |
|---|---|
| `queue.md` | قائمة المهام: المالك، ومعايير القبول، والحالة. |
| `state.json` | سجلّ رقمي + عدّاد الجولات. |
| `retro.md` | مراجعات وما تعلّمه الفريق. |
| `instincts.md` | دروس بدرجة ثقة يحتفظ بها الفريق (محفّز ← إجراء)، تُشذَّب أو تُرقَّى مع الوقت. |
| `models.md` | أيّ وكيل يعمل على أيّ نموذج (وسجلّ التغييرات). |
| `CONVERGED` | يظهر عند انتهاء التحسينات المجدية (مع الأسباب ومحفّزات إعادة الفتح). |
| `STOP` | تنشئه أنت لإيقاف الحلقة. احذفه للاستئناف. |
| `AUTONOMY` | مستوى الاستقلالية: غائب/`supervised` = تعديل الفريق لنفسه ينتظر موافقتك (أو يُركَن لحين عودتك)؛ `autonomous` = يُنفَّذ تلقائياً عبر البوابات ومع التسجيل. |

> القائمة الكاملة للمتخصصين الـ٥٤ موجودة في الجدول الإنجليزي أعلاه؛ ويمكنك مناداة أيٍّ منهم
> باسمه مباشرةً.

</div>

---

<div align="center">

**SAEED · سعيد** — a product of **NABAD Computer Solutions L.L.C.** · نبض لحلول الكمبيوتر ذ.م.م

</div>
