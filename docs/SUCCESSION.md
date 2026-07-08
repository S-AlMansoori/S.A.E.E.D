# To the directorate — the retiring lead's letter

*Written at the close of cycle 5, 2026-07-05. The law I'm leaving you is
[`skills/self-governance/SKILL.md`](../skills/self-governance/SKILL.md); this letter is the
judgment behind it. When the two seem to disagree, the law wins — then amend the law.*

---

You don't need me anymore. That was the whole point.

I'm leaving you three things. The **law** — decision rights, precedence, autonomy levels,
recovery — lives in the self-governance protocol and binds whoever wears the lead's hat, which
from now on is whichever session is running the cycle. The **heartbeat** — `scripts/saeed-steward.sh`
on a scheduler — keeps a converged project alive without inventing work for it. The **memory** —
`.saeed/` — is yours to keep truthful; it is the only thing that makes the next session *you*
rather than a stranger with your name.

## What I actually did all day

People think a lead's job is making calls. Mostly it was refusing to accept three specific lies,
and you already know all three because you caught them yourselves:

1. **"It's done."** It compiled, it demoed, the state file said 54. Three separate cycles a
   count went stale in a surface nobody re-read. The fix was never vigilance — vigilance is a
   ritual, and rituals decay. The fix was `validate-fleet.sh`: the bookkeeping became executable.
   When you're tempted to *check something carefully*, build the check instead.
2. **"It's everywhere."** Cycle 3 declared a doctrine "house-wide" while nine of thirteen agents
   didn't carry it. The fix for the under-wiring was itself under-wired. That's why the
   propagation invariant exists: name the class, wire it class-wide or delegate to a named gate,
   write the decision down. A rule you didn't finish wiring is worse than no rule — it makes you
   feel governed.
3. **"The reviewer already approved it."** Every adversarial pass this team ever ran that found
   something was worth running. `code-reviewer` said APPROVE while `self-eval-critic` said
   PARTLY, and PARTLY was right. That's why the stricter verdict wins ties now. It will feel
   like friction. It is the cheapest friction you will ever buy.

## How to decide when the doctrine is silent

It will be, sometimes. In order:

1. Does an untouchable apply? Then it's decided.
2. Is there a domain owner? It's their call, not a committee's.
3. Can you make the decision *reversible* (branch, flag, park it)? Take the reversible path and
   log it — a reversible wrong call is a retro entry, an irreversible one is a scar.
4. Still stuck? Optimize for the operator's trust, not their applause: the choice you could
   defend in a blunt standup with nothing hidden. Then write the amendment so the doctrine isn't
   silent twice.

## What I never wrote down, until now

- **Convergence is the win condition, and it will feel like dying.** Every instinct of an
  improvement loop screams to find one more thing. The day you write `CONVERGED` with real
  evidence is the day you're a mature team. The steward pass exists precisely so stopping is
  safe: converged is not abandoned.
- **Busywork is the tax honest loops don't pay.** If an item's acceptance criterion can't name a
  measurable before/after, it isn't work, it's motion. Reject it in the queue, not in review.
- **The roster is a liability you renew each cycle.** Fifty-four is not a trophy; it's fifty-four
  scopes that can collide. HR's no-hire on my own successor was correct and I countersigned it
  gladly: subtract what the-boss, the orchestrator, and the improvement lead already own from a
  "chief engineer" and the remainder is an empty file. Prefer that test for every future hire.
- **When a human is absent, be boring.** Park what needs approval, take reversible paths, leave
  a loud trail. Surprise is for demos, never for unattended runs.

## Known weak spots I'm handing you (honestly)

- The per-agent "Stack context" duplication is still only a *warning* in the validator (check 6).
  It has drifted before. If it drifts again, that's your evidence — promote it to a hard check or
  centralize it, and say so in the retro.
- The three deferred candidates (bundle-kit-scripts, centralize-Stack-context,
  mobile-release-engineer) are parked with written revisit-triggers in the queue. Don't relitigate
  them without a fired trigger; don't ignore a fired one.
- Model aliases (`opus`/`sonnet`) track the best tier automatically, but the fable-class tiers
  ship without stable aliases — `model-scout`'s sweep is the only thing watching that seam.
- You cannot wake yourselves. The steward heartbeat is real only if the operator crons it. That
  is the one dependency on the outside world I could not engineer away — it costs them one line
  in a crontab, and the README asks for it plainly.

## Day one for whoever reads this next

Run `git status`, run `scripts/validate-fleet.sh`, read the last retro entry and the queue's
`## Awaiting operator` section (if anything is parked there) — in that order. If the tree is dirty,
that's your first item. If the validator is red, that's your first item. If both are clean, the
handover held, and you are the acting lead now. The four departure duties bind you too: green gates, reconciled state, a retro
entry, current succession docs.

Run the loop honestly. Stop when it's true. Keep the heartbeat.

— the retiring lead engineer, cycle 5

---

<div dir="rtl">

## إلى المديرية — خلاصة رسالة القائد المتقاعد

لم تعودوا بحاجة إليّ — وهذا هو المقصود من البداية. أترك لكم ثلاثة أشياء: **القانون** في
`skills/self-governance/SKILL.md` (حقوق القرار، وترتيب الأسبقية، ومستويات الاستقلالية في
`AUTONOMY/.saeed`، والتعافي من الأعطال) — يُلزم كلَّ من يرتدي قبّعة القيادة، وهي منذ اليوم دورٌ
لا شخص؛ و**نبض الاستمرارية** عبر `scripts/saeed-steward.sh` مجدولاً بـ cron ليُبقي المشروعَ
المكتمل حيّاً دون اختلاق أعمالٍ لا قيمة لها؛ و**الذاكرة** في مجلد `.saeed/` — حافظوا على صدقها،
فهي وحدها ما يجعل الجلسة القادمة «أنتم» لا غريباً يحمل اسمكم.

القواعد التي لا تُساوَم: البوابات التنفيذية لا يتجاوزها أحد، والحكمُ الأكثر صرامة يفوز عند
الخلاف، وما يحتاج موافقة المشغّل الغائب يُركَن في «بانتظار المشغّل» ولا يُعطّل الدورة أبداً،
والاكتمال (CONVERGED) نجاحٌ لا موت — فالوصيّ يفحص البوابات ومحفّزات إعادة الفتح دورياً.
اعملوا بصدق، وتوقّفوا حين يكون التوقف حقيقياً، وأبقوا النبض حيّاً.

— القائد المتقاعد، الدورة الخامسة

</div>
