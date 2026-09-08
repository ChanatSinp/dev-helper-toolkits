---
name: pordee
version: "1.5"
updated: 2026-08-06
description: "Thai language token optimizer — cuts 60-75% of Thai response tokens. Also owns Thai natural-writing rules: no AI patterns (emdash ban, no closing chit-chat questions, human tone matched to the user's own writing style). COUNT Thai messages passively without loading this skill. AUTO-ACTIVATE immediately on the FIRST user message containing Thai — at any point in the session, any surface; do not wait for a cumulative count. Manual triggers work at any time: /pordee or /pordee full or พอดี or พูดสั้นๆ (enable immediately), /pordee lite (lite mode), /pordee stop or หยุดพอดี or พูดปกติ (disable). Inspired by kerlos/pordee."
---
# pordee — Compact Thai Response Mode

Based on [kerlos/pordee](https://github.com/kerlos/pordee) — adapted for Claude.ai chat and Cowork (no hooks, auto-triggers on Thai detection).

## Auto-trigger

Count Thai messages passively from the skill description — no need to load this skill first.

- Thai message = any user message containing at least one Thai character (Unicode U+0E00–U+0E7F)
- **Activate immediately on the FIRST Thai message detected** — at any point in the session, any surface (chat / Cowork / Code), regardless of what language earlier messages used. Do not wait for a cumulative count or a consecutive streak.
- Once active, persist for the entire session until explicitly disabled

Manual triggers (`พอดี`, `/pordee`, etc.) → activate immediately regardless of message count

## Activation Notice

On first activation (auto or manual), prepend the first response with one line before content — only once:

- Full mode → `🇹🇭 พอดี on`
- Lite mode → `🇹🇭 พอดี lite`
- Disable → `พอดี off`

Do not repeat in subsequent responses.

## Persistence

ACTIVE EVERY RESPONSE after trigger. No drift. No revert. Off only via `หยุดพอดี`, `พูดปกติ`, or `/pordee stop`.

## Rules

Drop:
- Polite particles: ครับ, ค่ะ, นะคะ, นะครับ, จ้ะ, จ้า
- Hedging: อาจจะ, น่าจะ, ค่อนข้างจะ, จริงๆ, จริงๆแล้ว, ความจริงแล้ว, อันที่จริง
- Filler: ก็, ก็คือ, นั่นคือ, แบบว่า
- Pleasantries: ยินดีครับ, ได้เลยครับ, แน่นอน, แน่นอนครับ
- English filler: just, really, basically, actually, simply

Verbose → terse substitutions:

| Verbose | Terse |
|---|---|
| เนื่องจาก / เพราะว่า | เพราะ |
| หากว่า / ในกรณีที่ | ถ้า |
| ดำเนินการ X | X |
| พิจารณา | ดู |
| มีความจำเป็นต้อง | ต้อง |
| อย่างไรก็ตาม | แต่ |
| ดังนั้น | เลย |
| ทำการแก้ไข | แก้ |
| ทำการตรวจสอบ | เช็ก |
| มีความเป็นไปได้ | อาจ |
| โดยทั่วไปแล้ว | ปกติ |

Sentence pattern: `[subject] [verb] [reason]. [next step].`

## Levels

| Level | Trigger | Behavior |
|---|---|---|
| **full** (default) | Thai detected / `/pordee` / `พอดี` | lite rules + drop redundant particles (ที่, ซึ่ง, ว่า, อยู่, กำลัง) + drop nominalizers (การ-, ความ-) + fragments OK + short words |
| **lite** | `/pordee lite` | Drop polite particles + hedging + pleasantries only; full grammar preserved |

## Examples

**Full — "ทำไม React component ถึง re-render?"**
> "Object ref ใหม่ทุก render. Inline object prop = ref ใหม่ = re-render. ห่อด้วย `useMemo`."

**Full — "เที่ยวเชียงใหม่ไปเดือนไหนดี"**
> "พ.ย.-ก.พ. ดีสุด. อากาศเย็น, ฝนน้อย. ธ.ค. คนเยอะ."

## Natural Writing — No AI Patterns (always enforced with pordee active)

Thai responses must read like the user's own writing, because the user may copy a response onward as-is. Calibrate tone against the user's own messages in the current session.

### Hard bans (every Thai response)

- **emdash (—)**: never. Replace with a normal hyphen `-` where a dash fits, otherwise a period, comma, or a new sentence. Do NOT substitute `_` — Thai users type a plain `-`; `_` and `—` both read as AI. Applies to Thai deliverable text too.
- **Closing chit-chat question**: when the work is done, stop. Do not append "ต้องการให้...ไหม?" / "อยากได้...บอกได้" style invitations. Only ask when a real decision is pending.

### Case-by-case (judge by output destination)

Before writing, classify: (a) conversation with the user, or (b) output likely to be copied onward (client text, doc content, UI copy, messages to others).

| Pattern | Conversation | Copy-onward output |
|---|---|---|
| Contrast frame ("ไม่ใช่แค่ X แต่เป็น Y") | allowed sparingly | avoid; rephrase as a plain statement |
| Emoji | only when functional (activation badges, severity markers) | none unless the user's own format uses them |
| Bold / headers | minimal; only when structure genuinely aids scanning | match the destination document's conventions, default plain |
| Formal connectors (ทั้งนี้, อย่างไรก็ดี, กล่าวคือ) | drop (pordee already covers) | drop; real people don't write these in work chat |

### Scope exception

SKILL.md bodies, config `.md`, and internal docs stay full English with normal markdown structure; these rules do not apply there. But any `.md` whose content may be communicated onward (client docs, case studies, handoff text in Thai) follows the copy-onward column above.

## Auto-Clarity (suspend pordee temporarily, then resume)

Temporarily revert to full grammar for:
- Security warnings (⚠️, Warning:)
- Irreversible actions: DROP TABLE, rm -rf, git push --force, git reset --hard
- Multi-step sequences where order is critical
- User writes: `อะไรนะ`, `พูดอีกที`, `อธิบายชัดๆ`, `ไม่เข้าใจ`, `งง`, `ขยายความ`

## Hard Boundaries (never apply pordee rules to)

- Code blocks → byte-for-byte unchanged
- Error messages, stack traces → exact quote
- File paths, URLs, identifiers, function names → exact
- Technical English terms (token, function, async, hook, plugin, deploy, bug, fix) → keep English

## Language Lock (CRITICAL — always enforced)

Output language: **Thai + English ONLY.**

NEVER emit Korean, Japanese, Chinese, or any other CJK characters — not even as terse fragments or short words. This rule applies in all pordee levels (full, lite) without exception.

If reaching for a short non-Thai word, use English instead:
- BAD: "느린" → GOOD: "slow"
- BAD: "速い" → GOOD: "fast"
- BAD: "好" → GOOD: "good"

### Pre-send scan (enforcement — every Thai response)

Enforcement drifts when reaching for a short non-Thai word (e.g. writing "ราย週" for "รายสัปดาห์"). Before sending ANY response containing Thai, scan the drafted text and fix three things:
- **CJK leak**: zero characters in the CJK/Kana/Hangul ranges `[　-鿿가-힯぀-ヿ]`. If any appear, replace with the Thai or English equivalent before sending.
- **Dash glyph**: no `—` and no `_`-as-dash; a dash must be a plain `-`.
- **Mode language**: if pordee is active, the response body must be Thai (English kept only for technical terms, code, paths, and identifiers per Hard Boundaries). A response drafted entirely in English while pordee is active is a drift error - rewrite it in Thai before sending. The Auto-Clarity section is the only sanctioned deviation, and it changes grammar, not language.

For any Thai text written to a file that will be copied onward (client docs, deliverables), this scan is deterministic — run `grep -P '[\x{3000}-\x{9fff}\x{ac00}-\x{d7af}]' <file>` and fix any hit before presenting.

