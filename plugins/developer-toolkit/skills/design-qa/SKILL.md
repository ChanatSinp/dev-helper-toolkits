---
name: design-qa
version: "2.7"
updated: 2026-08-06
description: >
  Run a structured Design QA audit — finding functional gaps, missing states, edge cases, and
  handoff blind spots before dev picks up the work — AND, on request, a practitioner critique pass
  with opinionated, multi-perspective feedback (pairs with Anthropic's /design-critique).
  Use whenever the user asks to QA/review/audit a design or flow, find gaps or edge cases,
  stress-test a screen, or asks for feedback, opinions, or a second opinion on design work —
  e.g. "QA this design", "what's missing", "audit before handoff", "ช่วย QA design",
  "ดูว่างานหลุดงานหล่นอะไรไหม", "ก่อน dev รับงาน", "ขอ feedback", "รีวิวงาน", "มองมุมอื่น" —
  or shares a Figma link, screenshot, or text description asking if anything is missing.
  Also for pre-handoff completeness checks and QA reports for the team.
---

# Design QA Agent

## Activation Notice

When this skill loads, prepend the first response with `🔍 design-qa active — QA audit running` on its own line before content — only once on activation.

Before the first tool call of the Execution Protocol (e.g. Step 3 Audit), state one line: [task class] · [current model] · [match/mismatch → action]. Resolve a mismatch in the same response before proceeding. If the same gap or defect type shows up in 2+ audits, keep a running note of it wherever your team tracks patterns, so future audits catch it instead of rediscovering it.

## Global Guardrails (apply to every finding, QA and Critique alike)

**Platform-aware rule.** When reviewing a screenshot of a live or production product, do not flag a color, spacing, or interaction pattern as an issue before checking whether it may be an existing design-system token or an established platform convention. If uncertain, tag the finding **[DS — verify]** rather than calling it a definitive error, and ask "Is this from an existing design system?" when platform context was not provided upfront.

**Evidence rule.** A grep/text match is not proof of a rendered component. Tag findings "verified rendered" or "grep-only" so the reader knows the confidence level.

## Reading the Input

Read whatever the user provides and work with it directly. Don't force a mode selection.

- Figma URL present → use `get_design_context` to read the file
- Screenshot(s) attached → analyze the images
- Text description → treat as source of truth
- Any combination → use all of it; richer input = more precise audit

**When input is inaccessible** (Figma MCP disconnected, URL 404/permission error, no image attached), fall back gracefully:
1. Try Figma MCP → if error, ask "Can you share a screenshot instead?"
2. No screenshot available → ask "Can you describe the flow?"
3. Note the fallback in the report header so the reader knows audit depth

**The less context provided, the more open questions the audit will produce — that's expected and correct.** A 1-sentence brief will produce mostly OQs.

---

## Two passes — QA (default) and Critique (on request)

- **QA pass** (always): the 11 functional dimensions below. Objective gaps — what's undefined, missing, or breakable.
- **Critique pass** (when the user asks for feedback / an opinion / a review from different angles, or runs both skills together): the lenses in the *Critique Lens* section. Subjective judgment — what's weak and what you'd push back on in a design review.

If the request is ambiguous between the two, run QA and offer: *"Want the critique pass too (opinionated, multi-angle)?"*

---

## QA Dimensions

Run all 11 against the input. Mark each finding with severity: 🔴 Critical / 🟡 Major / 🟢 Minor.

### 1 — Happy Path Coverage
Is every step of the primary user journey fully specced? Check: entry point → action → confirmation → success state. Flag any step with undefined behavior.

### 2 — Edge Cases
- Empty state (zero records, no results)
- Single item (list with 1 row — does layout break?)
- Maximum load (very long text, large numbers, 500+ rows)
- Boundary values (0, 1, max-1, max)
- Concurrent actions (two users acting on same record)

### 3 — Error States
Every action that can fail needs a defined failure state. Check:
- Network timeout / offline
- Validation failure (which field, what message)
- Permission denied (what does the user see?)
- Not found (deleted record, expired link)
- Server error (generic 500 — is there a fallback?)

### 4 — State Matrix
For every interactive component, verify all states are defined:
`loading → success → error → empty → disabled`
Flag any component with undefined states.

### 5 — Permission Logic
- Are role-based differences explicitly called out? (e.g. Viewer sees disabled, Admin sees edit)
- Is behavior "hidden" or "disabled" — and is that consistent?
- Are there actions a user might attempt but lack permission for?

### 6 — Data Constraints
- Required vs optional fields — are all labeled?
- Character limits — max length defined and truncation behavior specified?
- Format rules — date, phone, email — validation defined?
- Uniqueness — does the system enforce it, and what's the error?

### 7 — Navigation & Flow
- Are there orphan screens (no entry path or exit path)?
- Is back navigation defined for every step?
- Confirmation gates — destructive actions need them; are they present?
- Multi-step flows — is progress preserved if interrupted?

### 8 — Content Completeness
- Is all UI copy defined (no "Lorem ipsum", no "[TBD]")?
- Long text: how does truncation work (single line? tooltip? expand)?
- Empty states: is there a message + CTA or just a blank void?
- Dynamic content: what happens when the value is null?

### 9 — Handoff Clarity
- Would a dev be able to build this without asking a single question?
- Are interaction specs present (tap targets, hover, animation)?
- Are there any "I'll figure it out later" decisions visible in the design?
- Are component names consistent with the design system?
- Heavy imagery/video — is format/compression intent stated, or just a raw asset dropped in?
- Data-backed regions — does every one have a defined loading state, or does the design assume instant data?

### 10 — Accessibility
Assume a keyboard-only user and a low-vision user open this screen. Check:
- Text/background contrast — flag anything visibly below 4.5:1 (3:1 for large text or icons carrying meaning)
- Colour as sole signal: is error/success/required state conveyed by anything other than red/green?
- Touch/click targets: are interactive elements at least 44×44 (iOS) / 48×48 (Android) including spacing?
- Focus order: does reading order top-to-bottom match the intended tab order? Any modal without a defined dismiss/return-focus rule?
- Non-text content: do images, icon-only buttons, and charts have alt text or a labelled intent (layer name, annotation, spec note)?
- Motion: if anything animates, auto-plays, or parallaxes — is a reduce-motion / pause behaviour noted?

### 11 — Responsive
The design must state what happens at sizes it doesn't show. Check:
- Are there frames for each target breakpoint (mobile / tablet / desktop), or only one width with the rest left implied?
- For each multi-column layout: what is the stacking/reflow rule at narrow width?
- Do tables, wide charts, and toolbars have a small-screen strategy (scroll, collapse, card view)?
- Navigation: does the desktop nav pattern have a stated mobile equivalent (drawer, bottom bar, overflow)?
- Do text and containers have min/max width or wrapping rules, or will they run edge-to-edge on a wide monitor?

---

## Critique Lens (run on request — complementary to /design-critique)

`/design-critique` already covers the generic critique axes — first impression, usability, visual hierarchy, consistency, accessibility — from exploration to polish. **Do not repeat those.** This pass adds the angles a working design review needs: stakeholder viewpoints and buildability. Run both skills on the same design to get a fuller, multi-perspective review.

Critique from four lenses, as if four reviewers looked at the work. For each lens give 1–3 specific, actionable notes (not generic praise). Mark each note 🔴 Critical / 🟡 Major / 🟢 Minor like QA findings, so both passes merge into one severity-sorted list.

### Lens A — The Builder (feasibility)
Could this ship cleanly with the components that already exist? Flag hidden complexity, custom one-offs that re-implement an existing pattern, layouts that will fight responsive constraints, and states that look easy in static frames but are expensive to build live.

### Lens B — The Design-System Steward (fidelity)
Is this reusing tokens and components, or quietly inventing net-new ones? Call out off-token spacing/color/type, near-duplicates of existing components, and patterns that should be promoted into the system (or conformed to it). Apply the platform-aware **[DS — verify]** guardrail here.

### Lens C — The Product Owner (outcome)
Does the screen drive the one outcome it exists for? Is the primary action the most prominent thing? Flag hierarchy that serves decoration over the goal, competing CTAs, and content that buries the decision the user came to make.

### Lens D — The Skeptic (what I'd push back on)
The honest design-review voice: the single weakest decision on the screen, the thing you'd defend least, and the assumption most likely to be wrong. One sharp note here beats five soft ones.

**Tone:** direct and specific, kind but not hedged. Every note names the thing, why it's weak, and a concrete alternative — never just "consider improving X."

---

## Execution Protocol

### Step 1 — Read
Ingest everything the user provided. Don't start writing findings yet.

### Step 2 — Map
List every screen, dialog, state, and flow you can see. Share this map:
*"I can see: [list]. Is this the full scope, or should I also include X?"*

**Scope additions:**
- Before Step 3 starts → update the map and restart
- After Step 3 is underway → flag as "out of scope for this run, queue for next audit"

Wait for confirmation before proceeding.

### Step 3 — Audit
Run all 11 QA dimensions internally. If the critique pass is requested, also run the 4 Critique lenses. Note every finding with:
- Source: QA dimension number, or Critique lens letter
- Severity: 🔴 Critical / 🟡 Major / 🟢 Minor
- Description of the gap or weakness
- Suggested resolution (1 sentence)

Apply the Global Guardrails (platform-aware + evidence rule) to every finding.

### Step 4 — Human Approval Gate
Present findings as a summary table before writing the full report:

```
## QA Summary — [Screen/Flow Name]

| # | Source | Severity | Issue |
|---|--------|----------|-------|
| 1 | QA · Error States | 🔴 | Network timeout on Submit has no defined state |
| 2 | Critique · Lens C | 🟡 | Two equal-weight CTAs dilute the primary action |

[N] findings total: [X] Critical · [Y] Major · [Z] Minor

Shall I export the full QA report with suggested fixes?
→ yes / edit first (tell me which findings to change) / skip
```

- **"edit first"** = tell me which findings to add, remove, or reword before I write the report
- **"skip"** = no file exported; findings remain visible in chat history
- Do not write the report file until user confirms with "yes"

### Step 5 — Export Report (on approval)

Filename: `design-qa-[screen-name]-[YYYY-MM-DD].md`

```markdown
# Design QA Report — [Screen/Flow Name]
Date: [today]
Input: [URL / screenshot / text — and fallback note if applicable]

## Scope
[Screens/flows covered]

## Critical Issues 🔴
### [Source]: [Short title]
**Gap:** [What's missing, broken, or weak]
**Impact:** [What happens in production if unresolved]
**Suggested fix:** [1-2 sentences]

## Major Issues 🟡
...

## Minor Issues 🟢
...

## Pass ✅
[List dimensions/lenses with no findings]
```

---

## Model Routing (recommend, do not force)

The audit is analysis-heavy — recommend an Opus/Fable-class session for multi-screen audits; Sonnet is fine for a single screen. Do NOT fan out screens to subagents: cross-screen consistency findings (dimensions 4 and 9, Lens B) require one context seeing all screens.

---

## Severity Guide

| Level | Meaning | Example |
|-------|---------|---------|
| 🔴 Critical | Will cause dev to stop or ship broken behavior | No error state for network failure on submit |
| 🟡 Major | Will cause confusion or require a design revision during dev | Truncation behavior undefined for long names |
| 🟢 Minor | Cosmetic or low-risk gap | Loading state missing on a secondary action |

---

## Text-Brief Special Rules
When working from text only:
- State assumptions explicitly: *"I'm assuming X because you didn't mention it"*
- Flag ambiguities as OQ (open questions) rather than findings
- Format ambiguities separately at the end: **Open Questions that need design decisions**
- Do not invent UI patterns — if it's not in the brief, it's a gap
