---
name: qa-testgen
version: "4.6"
updated: 2026-08-06
description: >
  Generate traceable QA artifacts — test plan, test cases, UAT checklist — from ANY input:
  epic-*.md (AC/EC/OQ), Figma flow, screenshot/wireframe, text brief, or live staging URL.
  CSV-first output for Google Sheets (test plan stays Markdown). Every case traces to an
  AC/EC ID, coverage is measured, and project domain rules are regression-tested automatically.
  In-development diff decisions are persisted to a diff-log before any deliverable is generated.
  Use when the user wants test cases, a test plan, a UAT checklist, coverage check, tests derived
  from a design/flow/screen, or QA of a staging build. Thai triggers: เขียน test case, ทำ test
  plan, uat checklist, เทสเคส, แผนทดสอบ, ออกเทสจาก epic/figma/url, qa staging,
  ครอบคลุมเทสไหม, regression set, ส่งงานให้ tester.
---

# QA Test Generator

## Activation Notice

When this skill loads, prepend the first response with `🧪 qa-testgen active` on its own line — only once on activation.

Before the first tool call of any generation run (multi-artifact build), state one line: [task class] · [current model] · [match/mismatch → action].

## Session Persistence

Once loaded, these rules apply to all subsequent test-generation tasks in the session without re-invocation. If the user moves to another epic ("now Epic C"), apply this checklist automatically.

---

## What This Skill Produces

CSV-first by default. Five artifacts per run, from one source — only the Test Plan is Markdown:

| Artifact | File | Purpose |
|----------|------|---------|
| **Test Plan** | `test-plan-{epic}-{YYYY-MM-DD}.md` | Scope, approach, environments, entry/exit criteria, risk areas (only `.md` artifact) |
| **Test Cases** | `test-cases-{epic}-{YYYY-MM-DD}.csv` | Executable cases, Given/When/Then merged into the row, fully traced to AC/EC. No separate `.md` run-sheet by default. |
| **Traceability Matrix** | `traceability-matrix-{epic}-{YYYY-MM-DD}.csv` | Split out from test cases — one row per AC/EC/observed node, coverage status. |
| **Test Case Summary** | `test-case-summary-{epic}-{YYYY-MM-DD}.csv` | Structure overview — one row per module/area: case count × type × focus × risk, plus a TOTAL row. **Default — generate every run**, counts computed from the actual case list (never hand-tallied). |
| **UAT Checklist** | `uat-checklist-{epic}-{YYYY-MM-DD}.csv` | Designer-run pass/fail with severity tagging. No separate `.md` by default. |

All CSVs are generated from the same internal case list in one pass — regenerate all of them together if the case list changes, never hand-edit one in isolation. Only produce a `.md` test-cases/UAT file if the user explicitly asks for it.

**Never merge a blank/fillable template with a completed-results file into one artifact**, even when their columns/checkpoints overlap. Split by artifact role, not content similarity: a worksheet meant for someone to fill in and a report of what was already found serve different audiences and must stay separate files.

**Supersession is per-artifact, not per-round.** When asked whether a newer dated round replaces an older one, answer file-by-file (e.g. only the UAT checklist may be superseded while test-cases/traceability/summary are not) — never give a blanket yes/no across the whole round.

**Default to archive over delete** for superseded QA artifacts (move to an `archive/` subfolder) unless the user explicitly says delete.

**When reusing a prior epic's artifact as a template** (bug list, UAT sheet, column layout), audit it for classification errors or naming choices first and report them — do not silently inherit a mistake (e.g. wrong column names, bugs mixed with improvements) into the new epic's version.

---

## In-Development Diff Log (governs overrides)

When the user supplies in-development diff decisions (sticky-note screenshots, verbal edits, or a numbered list) that override the base `epic-*.md` without editing it, **write them to `diff-log-{epic}-{YYYY-MM-DD}.md` FIRST** — before generating any deliverable. Format: numbered list matching the user's own numbering + a one-line scope statement per item (what's added / removed / changed). This file is the override source of truth; the base `epic-*.md` is never edited.

Never run a subagent audit until the governing diff-log exists — an audit against decisions that live only in chat will false-positive against them.

---

## Input Modes & Source of Truth

Detect the mode from what the user provides. Accept any combination. The **coverage baseline** (what every case must trace to) differs by mode — this is the key adaptation, not just how you read the input.

| Mode | Input | How to read | Coverage baseline |
|------|-------|-------------|-------------------|
| **Spec** | `epic-*.md` | parse AC/EC/OQ nodes (below) | AC/EC IDs |
| **Figma** | `figma.com` URL | `get_design_context` → screens, states, actions | observed screens + states + actions |
| **Image** | screenshot / whiteboard / wireframe | analyze the image directly | observed screens + states |
| **Text** | prose brief | treat as source of truth; state every assumption | enumerated requirements |
| **Live** | staging / preview URL | Claude in Chrome (`navigate` → `read_page`/`get_page_text`); if no browser available, ask for screenshots | observed pages + flows + **actual** behavior |

**Priority when several are given:** live build / Figma (what the UI actually is) > `epic-*.md` (story intent) > image > text. If a live build and the spec disagree, the build is what exists — test both and flag the divergence as a finding.

### Spec mode — parsing an epic-*.md
Nodes are sticky-note blocks:
- `[A01]` = story root (title + persona goal)
- `[A01AC01]` = Acceptance Criteria, carries `[Permission: …]`
- `[A01EC01]` = Edge/Error Case, carries `[Severity: Critical|Major|Minor]`
- `[A01OQ01]` = Open Question — **not yet testable**; list under "Blocked / pending decision", do not invent a case for it.

Extract every AC and EC ID before writing any case. The ID list is the coverage baseline.

### Spec-less modes (Figma / Image / Text / Live) — build the baseline yourself
There are no AC/EC IDs, so construct one: enumerate every **screen, state, action, input field, and decision branch** you can observe, give each a stable label, and trace cases to `OBSERVED-<label>` (e.g. `OBSERVED-ProviderList-Filter`). The coverage rule is unchanged: every observed element → ≥1 case; anything you cannot resolve → list as an Open Question, do not fabricate behavior. The **Domain Regression Set still applies in every mode.**

**Live mode — extra rules:**
- The **actual** rendered behavior is the expected result. Read real responses, validation, and error states — do not assume from the spec.
- **Read/inspect only.** Never submit destructive actions, move money, or create real records on a staging build. Mark such paths `manual-execute` for the tester instead of triggering them.
- Verify the URL with the user before navigating if it is at all unfamiliar; treat it as the user's own environment.
- Never mark a bug confirmed from a single DOM/network pass alone. Reproduce it, AND cross-check against the user's own existing test results/sheet if provided. If your finding conflicts with the user's recorded result, flag the conflict — don't overwrite it with your own read.

---

## Test Case Format (Hybrid)

Each case = a Given/When/Then scenario header (for traceability + intent) **plus** a numbered step-table (for execution). One case, both layers.

```
### TC-A01-03 — Filter providers by Active status
**Covers:** A01AC02   **Type:** Positive   **Priority:** High
**Scenario:**
- Given — อยู่หน้า Provider List มี provider ทั้ง active และ inactive
- When — เลือก filter Active = "Active"
- Then — ตารางแสดงเฉพาะ provider ที่ Status ≠ Inactive

| # | Step | Expected Result |
|---|------|-----------------|
| 1 | เปิดหน้า Provider List | ตารางแสดง provider ทั้งหมด + Total count |
| 2 | คลิก filter **Active** → เลือก "Active" | ตาราง refresh แสดงเฉพาะ Active provider |
| 3 | ตรวจ Status column | ไม่มีแถวที่ Status = Inactive |
```

**Type values:** `Positive` (happy path, from AC) · `Negative` (failure/guard, from EC) · `Edge` (boundary/empty/max) · `Regression` (domain rule, see below).

**Priority:** `High` (blocks core flow or money path) · `Medium` (secondary flow) · `Low` (cosmetic/rare).

---

## ID & Traceability Convention

- Test case ID: `TC-{StoryID}-{nn}` → `TC-A01-01`, `TC-A01-02` …
- Negative cases keep the same sequence; the `Covers` field points to the EC: `Covers: A01EC02`.
- A regression case (domain rule, not story-specific): `TC-REG-{nn}`, `Covers: CONVENTION`.
- Spec-less modes: `Covers` points to an `OBSERVED-<label>` instead of an AC/EC ID; case ID uses the screen label, e.g. `TC-ProviderList-01`.

### Coverage rules (enforced, not optional)
- Every **AC** (or observed element) → at least one Positive case.
- Every **EC** (or observed error/edge branch) → at least one Negative/Edge case, inheriting its severity.
- Every case's `Covers` must reference a real node ID, an `OBSERVED-<label>`, or `CONVENTION`.
- After generating, emit a **Traceability Matrix** and flag any AC/EC/observed element with **zero** cases as a coverage gap — do not silently skip.
- When a diff-log decision **removes** a component (e.g. bulk action), sweep ALL dependent artifacts — checkbox columns, select-all headers, row-selection logic, related test cases — and verify against the diff-log's scope statement, not just the primary mention. Cross-check this during step 4 Verify.

```
## Traceability Matrix — Epic A
| Node | Type | Covered by | Status |
|------|------|-----------|--------|
| A01AC01 | AC | TC-A01-01 | ✅ |
| A01AC02 | AC | TC-A01-03 | ✅ |
| A01EC02 | EC (Major) | TC-A01-09 | ✅ |
| A01AC07 | AC | — | 🔴 GAP |
```

---

## Domain Regression Set (always append)

Read the project's domain regression rules from the project root `CLAUDE.md` (its "Domain Regression Set" section) at run time, and append them every run as `TC-REG-{nn}` Regression cases. If the epic under test does not touch a given rule, still list it marked `N/A — not in this epic's surface` rather than dropping it, so the regression intent stays visible. If the project defines no regression set, skip this section. Do not hardcode product rules here — they live per-project.

---

## UAT Checklist (designer-run, severity-tagged)

The designer is the UAT tester. Keep it scannable; one line per checkpoint, grouped by story. Each checkpoint is the user-visible outcome (not an internal step), with a pass/fail box and a severity to tag if it fails — severity matches the EC scale: `Critical` (data loss / blocks release) · `Major` (needs fix before ship) · `Minor` (cosmetic / can defer).

```
## UAT — Epic A · Provider List (A01)

| ✓ | Checkpoint (user outcome) | Trace | If fails → severity |
|---|---------------------------|-------|---------------------|
| ☐ | Provider list loads with total count + refresh | A01AC01 | Critical |
| ☐ | Active filter narrows the table correctly | A01AC02 | Major |
| ☐ | Empty state shows "No providers found." with no CTA | A01AC08 | Minor |
| ☐ | Network timeout shows error + retry | A01EC02 | Major |
| ☐ | Project conventions hold (per project CLAUDE.md) | CONVENTION | Major |

**Bug log (fill on fail):** Checkpoint · Trace · Severity · What you saw · Screenshot
```

UAT covers the user-visible AC outcomes + the domain regression rules. It is lighter than the full test-case set — it confirms the build is acceptable, not exhaustive path testing.

UAT is designer/PO **acceptance**, judged by risk coverage of complex flows — NOT by test-case density. Do not flag UAT as thin for being lighter than the test-case set. Only add checkpoints to genuinely underweighted complex stories (multi-step wizards, branching flows).

---

## Output Mechanics

### Bilingual rule
- **Steps, expected results, scenarios, checkpoints → Thai.** Plain, unambiguous Thai a tester reads top-to-bottom.
- **Field names, UI labels, status values, node IDs, type/severity keywords → English**, inline, matching the epic exactly (e.g. `Status`, `Active`, `Submit`).
- Never translate an EN term that appears in the epic — mismatched vocabulary breaks tester trust.

### Tester-facing language
Write `Notes` and risk/rationale fields for the least-experienced tester who will run the sheet. No engine/spec jargon (WebKit, OQ, DSP) in tester-facing fields; keep node IDs and EN field names. When the audience is stated as junior/manual testers, plain-language the risk column by default.

### Downstream-runtime validation
When output correctness depends on a downstream runtime (game engine, target browser, real device), synthetic fixtures do not validate it. Test against pristine real assets, and mark any "looks right in static test" change as needing the user's downstream re-validation before it is trusted.

### Test Cases CSV (Google Sheets)
Columns, in order — Given/When/Then merged in, no separate `.md`:
`TC_ID, Story, Covers, Title, Type, Priority, Given, When, Then, Device, Precondition, Steps, Expected, Severity_if_fail, Result, Actual, Notes`

- `Result` left blank (tester fills Pass/Fail/Blocked via Sheets dropdown).
- `Device` defaults to `All`; override only where render/behavior differs per breakpoint (see Responsive dimension). Omit the column entirely if the target has no responsive breakpoints.
- `Steps` and `Expected`: number the sub-steps and separate with a newline **inside the quoted cell** (`"1. …\n2. …"`) so Sheets keeps them in one cell. Always quote these fields.
- **CSV integrity gate:** write the CSV with a proper csv writer (e.g. Python `csv` module) — never hand-typed rows. Emit every column explicitly, including empty trailing fields (`Result`, `Actual`, `Notes`). Before delivery, programmatically verify every row has the full column count.
- UTF-8, comma-delimited, header row first. Verify it opens cleanly (no broken Thai, no column shift) before delivering.

### Responsive dimension (default when breakpoints exist)
If the target (prototype, staging build, or spec) defines responsive breakpoints, read them **from the actual CSS/source** — never assume standard values. Then:
- Add the `Device` column as above, labeled by the discovered breakpoints (e.g. Mobile / Tablet / Desktop with their px thresholds).
- Add dedicated `TC-RWD-*` cases covering breakpoint-switch behavior: component swaps (e.g. bottom-sheet ↔ modal, drawer ↔ dropdown), grid column-count changes, layout stacking, and live resize across a breakpoint without visual glitch or state loss.
- Flag cases whose surface renders differently per breakpoint so the tester runs them on both sides.

### Subsequent rounds — diff from baseline, don't re-derive
When the project already has a generated test-case set from a prior round, do **not** re-derive from scratch. Load the prior set as the baseline, then add only cases for new/changed AC-EC IDs or new dimensions (e.g. a newly added breakpoint), and **preserve existing case IDs** — re-deriving churns IDs and breaks traceability. Persist the baseline file location + naming pattern in project memory so the next round continues cleanly.

Generate all CSV artifacts from the **same** internal case list in one pass.

---

## Model Routing (recommend, do not force)

When run under an orchestrator that can switch models, split by cognitive load:
- **Heavy (Opus):** parse epic, build the coverage map, derive edge/negative cases, reason about domain-rule exposure. This is where missed coverage hides.
- **Light (Sonnet):** mechanical expansion of confirmed cases into the step-table, bilingual fill, CSV formatting, matrix table rendering.

State the suggestion once at the start of a large run; the user switches.

**Subagent fan-out (multi-epic batch):** after scope is confirmed in the main session, fan out one Sonnet subagent per epic (bounded — never per story); each returns its case list + traceability matrix for merge in the main session. Single epic → generate inline. On an Opus/Fable-class orchestrator, the heavy phases run inline — do not spawn an Opus subagent for them. If your runtime has no sub-agent dispatch, work through epics one at a time inline instead of fanning out.

---

## Execution Protocol

### 1 — Detect mode, read & extract
Identify the input mode (Spec / Figma / Image / Text / Live) and read accordingly. Extract the coverage baseline — the AC/EC/OQ ID list, or the enumerated `OBSERVED-<label>` surface for spec-less modes. Do not write cases yet.

### 1.5 — Check cut/deferred status before scoping
Before mapping coverage, check the epic for stub cards (product-doc-coauthor convention: a deferred/cut node kept as a title-only stub, children deleted). Any AC/EC under a stub is CUT — exclude it entirely from cases, UAT checklist, and the traceability matrix. Do not list it as "deferred" or "still testable." If cut/deferred status is ambiguous for a node, ask before writing a case for it — never assume testable by default.

### 2 — Map & confirm scope
If in-development diff decisions apply, write the diff-log first (see "In-Development Diff Log") before anything else in this step.
Show: stories in scope, AC count, EC count, OQ count (blocked), and the domain regression set that will apply. If proposing CSV for UAT/checklist, state upfront that plain CSV cannot embed checkboxes or dropdowns — set the expectation before the user asks. Ask:
*"Scope = [list]. Generating N positive + M negative/edge + the project-defined regression cases. UAT covers the AC outcomes. Proceed, or adjust scope?"*
Wait for confirmation.

### 3 — Generate
Write test plan (.md) → test cases CSV (traced, GWT merged in) → traceability matrix CSV → UAT checklist CSV. Append the domain regression set. Generate all CSVs from the same case list in one pass.

### 4 — Verify (mandatory self-check)
Before delivering, confirm:
- [ ] Every AC ID has ≥1 case; every EC ID has ≥1 case — matrix shows zero 🔴 GAP (or each gap is explained, e.g. OQ-blocked).
- [ ] Every `Covers` references a real node ID or `CONVENTION`.
- [ ] All project-defined regression cases present (or marked N/A with reason).
- [ ] CSV opens clean: header row, no column shift, Thai renders, multi-step cells intact.
- [ ] No removed-scope artifact tested as if live, and no renamed-away labels used (per the project CLAUDE.md conventions).
- [ ] If a diff-log applies: every removal swept across all dependent artifacts, checked against the diff-log's scope statement.
- [ ] Test-cases CSV row count == traceability matrix coverage count.
- [ ] Every CSV row has the full column count (programmatic check, not eyeball).
- [ ] Summary CSV counts match the actual case list (computed, not hand-tallied).
- [ ] If breakpoints exist: `TC-RWD-*` cases present and `Device` overrides applied.
Report the matrix summary (`X AC / Y EC covered, Z gaps`) with the deliverables.

---

## What NOT to do

- Do not invent UI behavior absent from the epic/Figma — if untested-because-unspecified, list under "Blocked / pending decision (OQ)".
- Do not write a case whose `Covers` points at nothing.
- Do not translate EN field names into Thai.
- Do not hand-edit one CSV artifact without regenerating the others from the same case list.
- Do not drop a regression case because "this epic probably doesn't touch it" — mark N/A instead.
- Do not test `Delete` as a happy path — most flows have no hard delete; treat deactivate/inactive instead.
- Do not treat in-development diff decisions as settled and generate deliverables before they're captured in the diff-log — capture first, build second.
- Do not classify a failed/blocked checkpoint as a bug just because the test result says Fail/Blocked — check first whether it contradicts a specific, stated AC/EC. If no AC/EC defines the expected behavior for that scenario, classify it as an improvement (design/definition gap) instead, and say which AC is missing.
- Do not carry a prior epic's Rationale/Suggestion-style column naming into a new improvement list without checking — default improvement/issue lists to ordered ปัญหา (problem) then ข้อเสนอ (proposal) columns unless the user's own convention says otherwise.
- When asked to reorganize, archive, or version-control existing dated artifacts, do not jump straight to a folder/structure scheme. First state what actually changed or diverged between the versions — relationship-checking precedes restructuring.
