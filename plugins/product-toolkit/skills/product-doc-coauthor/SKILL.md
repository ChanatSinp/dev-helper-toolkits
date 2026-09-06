---
name: product-doc-coauthor
version: "3.10"
updated: 2026-08-06
description: >
  Co-author and maintain product user story documentation in sticky-note block format for ClickUp
  whiteboards. INVOKE PROACTIVELY — before starting the work, not after being asked. Trigger
  immediately whenever the task involves: reading or editing any epic-*.md file, writing or
  auditing user stories / AC / EC / OQ, deriving stories from wireframes or Figma screenshots,
  reviewing dependency impact across epics, or generating a change log. Also trigger when the
  user shares a design to document or asks to patch story content. Thai triggers: audit epic,
  เขียน story, เพิ่ม AC/OQ, แก้ EC/story, derive จาก wireframe, patch story, ตรวจ dependency,
  ทำ change log, ตรวจ epic. Once loaded, rules persist for all subsequent epic/story tasks in the
  session — do not re-invoke per task.
---

# Product Documentation Co-author

## Activation Notice

When this skill loads, prepend the first response with `📋 product-doc-coauthor active` on its own line — only once on activation.

Before the first Edit/patch of any audit, patch, or derive workflow, state one line: [task class] · [current model] · [match/mismatch → action]. When a scope or dependency decision sets a precedent (it would change how a future estimate or QA pass reads the epic), note it somewhere durable, not just in chat.

## Session Persistence

Once loaded, this skill's patterns and rules apply to **all subsequent epic/story tasks in this session** without requiring re-invocation. If the user starts a new epic task (e.g., "now let's work on Epic F"), apply this skill's checklist automatically — do not wait to be asked whether the skill is active.

If the current task involves an epic file or story content and this skill has NOT been loaded yet — stop, load it, then proceed. The skill must be active before any audit, patch, or derive work begins.

---

## Input Modes

Detect the mode from context. If ambiguous, ask.

| Mode | Trigger | How to read the design |
|------|---------|----------------------|
| **A — Figma MCP** | User shares `figma.com` URL | `get_design_context` → parse node tree, states, layers → derive stories |
| **B — Screenshot** | User attaches image(s) with remark | Analyze images directly — read all remarks first, then map images per index |
| **C — Text Brief** | User describes feature in prose, no visual | Treat description as source of truth — state assumptions explicitly, flag gaps as OQ |

**Mode A note:** Large frame nodes → timeout. Request child node ID or fall back to screenshot.

**Mode C rules:**
- State every assumption explicitly: *"I'm assuming X because you didn't specify it"*
- Flag ambiguities as `[StoryIDOQnn]`, not as AC
- Do not invent UI patterns — if not in the brief, spec it as OQ
- End every output with a block: **Open Questions that need design decisions**
  - Distinguish: inline `[StoryIDOQnn]` = unresolved detail mid-story / end-block OQ = design decision that blocks story writing entirely

---

## Output Format

### Sticky Note Block (one unit of work)
```
[{StoryID}{NodeType}{Number}]
One topic per block
[Permission: X] or [Severity: X] or [Owner: X]
```

### Node Types
| Type | Meaning | Example |
|------|---------|---------|
| (story root) | User Story | `[B01]` |
| `Entry` | Entry point | `[B01Entry1]` |
| `AC` | Acceptance Criteria | `[B01AC01]` |
| `EC` | Edge Case / Error Case | `[B01EC01]` |
| `OQ` | Open Question | `[B01OQ01]` |

### Permission Values
- `View` — read only
- `View, Update` — read + edit (includes Set Inactive)
- `View, Create, Update` — read + create + edit
- ❌ Never use `Delete` — most systems have no hard delete

### Severity Values (EC)
- `Critical` — data loss, network offline, multi-step form
- `Major` — conflict submit, validation, duplicate unique ID
- `Minor` — search behavior, pagination edge, inline error

---

## Story Structure Patterns

### List Page
AC order: Header → Filter bar → Table columns → Status badge → Special columns → Actions column → Table behavior → Empty state → Primary CTA

EC required: Search spec (partial match + Enter + searchable fields), Bulk Action behavior, Network timeout → retry

EC not needed: pagination size (if already in AC table behavior), status warning banner on page load

### Form Page
AC order: Form structure → Required fields → Optional fields → CTA → Success state

EC required: Network offline → cache local (Critical), Required field missing → inline error (Major), File format/size (Minor)

EC not needed: Concurrent conflict for generic forms (last-write-wins is sufficient)

### Inactive Dialog
AC required: Summary content → Confirmation input (type code/ID, button disabled until correct) → CTA + snackbar → Confirm behavior + Bulk mode

EC required: Concurrent conflict → error + reload (Major)

EC not needed: Impact warning banner before confirm (dialog + confirmation input already serve this purpose)

### Multi-State Page
- Each state = separate AC (State A / B / C)
- Shared behavior = AC appended after state-specific ones
- This is a full page, not a dialog — note this in story root
- State count is design-driven: if a new wireframe changes the number of states (e.g. 3 → 2), confirm the new count before rewriting — do not silently keep or collapse old states

### Multi-Step Wizard
- Step indicator = first AC
- Each step = separate AC
- EC: network drops mid-step → error dialog, data preserved (Critical)

---

## Reminder Banner Rule
Add a Reminder banner in CTA only for actions that affect the financial system:
- ✅ Add/Edit that affects fee or commission
- ❌ Add/Edit of metadata (name, logo, etc.)

---

## Index Rules
- AC and EC numbering is continuous within the same story
- Delete a node → renumber remaining nodes to stay sequential
- Add a node → append after the last index
- OQ index is separate from AC/EC
- Remapping content to an existing ID, or reordering any tab/node = renumber in the team's view — always notify the user first: "this action = renumber for the team" and wait for confirm before executing, no exceptions

---

## Workflow: Derive Stories from Wireframe

0. When the user sends multiple wireframes with remarks: read all remarks first, then map images by the index the user specified — do not assume sequence from visual order.
1. Read all wireframes first — map pages, dialogs, states, CTAs
2. Summarize the story list with IDs for confirmation before writing
3. Order by actual user journey (list → create → inspect → edit → deactivate)
4. Write story root → Entry points → AC (journey order) → EC → OQ
5. Add `Depends on:` in story root if a parent story exists

## Workflow: Derive Stories from Text Brief (Mode C)

1. Read the full brief — map features, user roles, specified actions
2. Summarize story list with IDs + assumptions for confirmation before writing
3. Write story root → Entry points → AC → EC → OQ
4. EC derived from brief only: apply severity from standard patterns, but flag as "assumed — verify from design"
5. End output with Open Questions block — items the brief doesn't specify and that require a decision
6. **Brief + existing file:** If a story file already exists → do not overwrite immediately. Surface the delta first: "Brief says X, file currently says Y — updating to X" then wait for confirm.

## Workflow: Audit & Repair

1. Receive sticky note screenshot or old file version
2. Compare against current file — map every ID
2.5 **Inherited risk check:** If the new doc references or depends on a story in another doc, scan the source doc for unresolved OQs, known logic bugs, or open design decisions. Flag each as:
   `[InheritedRisk] [SourceStoryID] has [issue] — verify before treating this dependency as stable.`
   Surface these at the top of the critic report even for indirect references.
3. Summarize diff before patching: IDs added / removed / changed / renumbered
4. Confirm with user before executing if changes affect a team currently working on the file
4.5 When an OQ is closed or a decision is resolved during the session, mark it immediately and exclude it from subsequent summaries
5. Patch using targeted Edit (single node) or Python via bash (batch renumber)
6. Verify with `grep -n` after patching
7. **Cross-reference hygiene:** when references change, also verify the document **header / front-matter reference lines**, not just the body. A doc is not "clean of stale refs" until its header block matches every doc it references and is referenced by.

## Workflow: Dependency Audit

When a design or product decision changes:
1. Identify the changed point directly
2. Find every story that references it (entry points, Depends on, AC that points to it)
3. Summarize impact table before updating
4. Update the file in one pass — do not split into multiple patches

---

## What NOT to Include in AC

| Do not include | Reason |
|----------------|--------|
| UI copy / helper text | Lives in wireframe, not story |
| Pagination size in EC | Already specified in AC table behavior |
| Impact warning before confirm inactive | Dialog + confirmation input already handle this |
| Concurrent conflict in generic forms | Last-write-wins is sufficient |
| `Delete` permission | Most systems have no hard delete |
| Status banner in EC on page load | Header/Summary badge already shown |

---

## System Conventions
Read product-specific conventions from the project root `CLAUDE.md` (its "System Conventions" section) at run time, and apply/flag against them. Do not hardcode product rules here — they live per-project. If no project `CLAUDE.md` exists, ask the user before assuming any convention.

---

## Source of Truth Priority

1. Figma — highest source of truth for UI/UX
2. Current .md file — source of truth for story content
3. Sticky note screenshot — use for comparison, may be an older version
4. Text brief — use when no visual is available; always state assumptions
5. In-chat memory — lowest priority; never assume without verifying

## Hallucination Anti-patterns
- Duplicate AC node IDs — always verify with `grep -n`
- Fabricated dialog flows not in Figma — verify before speccing
- Wrong field names — read wireframe before assuming
- Steppers not in the design — confirm from Figma before speccing
- Fields or behaviors from a previous reorder version — do not fill from old in-chat memory
- Mode C specific: do not invent UI patterns not in the brief — add as OQ instead
- "Already covered" claims: before declaring any story covers a behavior or exclude rule, grep-verify the current file. Never conclude "already covered" from in-chat memory.
- Orthogonal property trap: do not model a property as a sub-attribute of an existing type if it applies across multiple types. Propose as independent property and confirm with user.
  Example: `delivery_method` applies to all item types — not a sub-attribute of any one type.

---

## Artifact Disambiguation
When a term could refer to multiple artifact types (e.g. "canon file" = spec file vs config file), state which artifact you mean explicitly before acting. Do not introduce ambiguous shorthand in your own framing — name the artifact (e.g. "the epic spec files", "the CI config") so the user can confirm without clarifying.

---

## Model Routing (recommend, do not force)

- **Heavy (Opus/Fable-class, inline):** derive stories, audit logic, dependency reasoning.
- **Light (Sonnet subagent OK):** batch renumber, change-log formatting.
- Multi-epic dependency audit → one subagent per epic, each returns an impact table; merge in the main session. If your runtime has no sub-agent dispatch, work through the epics one at a time inline instead.
- Recommend tier once at the start of a large run; the user switches.

---

## File Editing Tools

- Targeted Edit (exact string replace) — single node edit
- Python via bash — batch renumber or multi-node operation
- `grep -n` — verify after every patch
- **Fence integrity** — after any node insert/edit (any workflow), re-read the touched region and confirm codeblock fences are balanced (no stacked or unbalanced ``` ). Node inserts are the most common cause of fence corruption — verify, don't assume.
- Python heredoc (`cat > file << 'EOF'`) — full file rewrite

## Session Recovery

- Source of truth = the current epic file in the project folder.
- Read the project CLAUDE.md and the latest handoff note before starting a new session.

## Figma Integration

- `get_design_context` with `excludeScreenshot: False` for moderate-size nodes
- Large frame nodes → always timeout → request child node ID or screenshot instead
- Figma is source of truth — if file and Figma differ, trust Figma

---

## Change Log Format

```
## Epic X — Change Log vN

**Added**
- XxxACnn — added: [content]

**Changed**
- XxxACnn — [what changed]: [before] → [after]

**Removed**
- XxxACnn — removed: [reason]

**Renumbered**
- AC05 (was AC07) → AC05 — [reason]
```

## Deferred-node stub rule

When a spec node is deferred out of the current version, never delete its whole column/subtree on the whiteboard. Keep exactly one stub card — the node's story card — rewritten as:

```
[NODE-ID]
[DEFERRED vX.Y.Z]
<one-line reason>
Will be implemented in <target version / with which epic>
```

Delete all child cards (Entry/AC/EC/markers). The stub preserves cross-epic references and signals the node was deferred, not lost. When auditing, a fully deleted subtree that other epics still reference is a **Critical** finding.
