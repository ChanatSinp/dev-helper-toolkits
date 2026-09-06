---
name: prototype-build
version: "3.15"
updated: 2026-08-06
description: "Full build execution protocol for single-file HTML prototypes. Use whenever the user is building, editing, fixing, or iterating on HTML prototype code — even if they don't say /build explicitly. Invoke for any coding task in a design prototype context: adding features, fixing layout bugs, editing components, handling interactions, or debugging JS. Triggers on /build. Also applies when user shares an HTML file and asks for any change."
---

# Prototype Build Protocol

## Activation Notice

When this skill loads, prepend the first response with `🔨 prototype-build active` on its own line before content — only once on activation.

## Build constraints

- Output: single self-contained HTML file
- JS: vanilla only — no frameworks unless explicitly requested
- CSS: no external dependencies unless explicitly requested

## Anti-patterns (never default without a stated reason)

- **Generic gradient backgrounds** — no `linear-gradient(purple → blue)` / "AI hero glow" unless the brief specifies a gradient treatment.
- **Default Tailwind shadow classes** — no `shadow-md`/`shadow-lg`/`shadow-xl` as-is; use the project's actual elevation tokens, or a hand-picked value if none exist yet.
- **Inter-by-default** — don't reach for Inter/system-ui as a silent fallback; if typography isn't specified, ask or match the sibling prototype's existing stack — don't assume.
- **Rounded-xl-plus-shadow "AI card"** — a card treatment (radius + shadow + subtle border) copied from generic AI-tool output rather than the project's own component language.
- **Emoji as UI icons** — no emoji standing in for iconography in shipped UI chrome unless the spec calls for it.

## Pre-flight (confirm before writing any code)

These are per-project questions. Component and prototype patterns differ between projects — never carry a previous project's answers over as defaults.

- **Interaction format** — static screen spec (fixed frames + state/debug panel, no routing) or live navigable prototype? Default to **static spec** if unspecified. "Interactive" does not imply navigation or routing.
- **Interaction fidelity** — before the first build of any interactive gimmick, confirm target fidelity explicitly: real drag/physics vs placeholder. Never treat the word "placeholder" in a spec as the final intended fidelity; ask which it is.
- **Metaphor completeness** — when building a reveal/open metaphor, model the physical object fully: if the real action uncovers something, include the occluding layer (cover/lid/seal) before the reveal. Check the metaphor for missing physical parts before building.
- **Visual direction** — before the first build of any product UI, confirm aesthetic direction if not stated (e.g. gaming, e-commerce, enterprise SaaS, consumer mobile). Do not assume from genre alone.
- **Carousel / scroller / full-bleed contract** — lock ONE behavior contract up front; don't build it half at a time across rounds. The contract must answer, for THIS project: edge treatment (peek? bleed — to which edge?), snap behavior, bounded vs infinite loop, drag mechanics (incl. release on pointerleave), scrollbar treatment, and height rule. Bleed anchor: identify which container actually bounds the layout — viewport, content, or main container. With a persistent sidebar/nav, anchor to the main container (container units: `.main{container-type:inline-size}` + `100cqi`), never `100vw` (100vw bleeds under the sidebar). Treat "bleed", "clip", and "scrollbar width" as ambiguous terms: restate your interpretation in one line and get a yes before coding — do not infer a fix (e.g. scroll-snap) from them.
- **Color scheme change** — before executing, map every affected visual element (backgrounds, borders, text, icons, shadows, states) and confirm the full scope with the user first.
- **Image embed** — state format + estimated file size before proceeding.
- **Creative copy or Thai prose** — read existing content first, calibrate tone, then write. Don't invent voice.
- **Apostrophes in HTML attributes** — when using single-quote delimiters, escape `'` as `&#39;`.
- **Literal spec over instinct** — when the user gives a precise behavioral spec (e.g. "swap this content" vs "add a field", "confirm" vs "cancel"), implement the literal wording before applying pattern instincts. If your instinct diverges from the literal spec, flag the divergence before building — don't build your instinct and wait for correction.
- **Check existing spec before inventing** — before designing any new visual, interaction, or overlay, grep CLAUDE.md and existing prototype files for an established spec first. Don't invent a visual/domain model from first principles when the project likely already defines it.
- **Native OS surface boundary** — keyboard input, system pickers, camera UI, and other native OS surfaces are out of spec scope. Note "native, not spec'd" and stop — don't build a dedicated frame for them.
- **"Reference" scope** — when told to reference a sibling prototype, reference its structural/interaction PATTERN and token architecture only — never copy its visual design, chrome, or presentation (device frames, mockup styling). If which is meant is ambiguous, ask before building.
- **Lo-fi wireframe fidelity** — when building from a lo-fi wireframe, match its exact structural language (its own box/chip/track/class names) as the baseline. Do not add nav chrome, device frames, or card/pill styling unless explicitly asked. The wireframe's spec outranks a sibling prototype's visuals.
- **Structural-axis pre-flight** — before the FIRST build, grill the make-or-break layout axes, not just naming/scope: edge-to-edge vs framed, fluid vs capped width, nav vs no-nav, fixed vs viewport-scaled canvas. These cause full rebuilds, not patches.
- **Component layout contract** — before building any sized/grid component (cards, thumbs, galleries), lock the contract in one line and confirm: bound-to-what (card/viewport/container), aspect or contain rule, grid columns at EVERY breakpoint, fixed vs fraction positioning. Never fix sizing symptom-by-symptom — a wrong contract means re-locking the contract, not patching the symptom.
- **Ask before building the unconfirmed** — distinguish "ambiguous but bounded" (an implementation detail whose shape is knowable from context already given — safe to build + flag) from "ambiguous and foundational" (a feature not yet confirmed in scope, or a domain/native-platform fact you don't actually know) — the second kind must be asked before building, not built-then-corrected. Default the base build to happy-path only; list speculative or variant branches as a question in the same message instead of building them preemptively.
- **Object-model check before speccing from mockups** — a mockup shows how a thing looks, never what it IS in the system. Before designing around any element (video, overlay, panel), state your assumption about what it is in the app's object model in one line and get a yes. Do not infer the model from the picture.
- **Control-convention check** — any control with an established name in the industry (zoom, fit, trim, snap, scrub) gets checked against real tools in that domain before proposing values or behavior, AND checked for how many meanings that word already carries inside this same app. Reusing a word that already means something else in-product is a naming bug, not a detail.
- **Scope-lock check before any standard control** — undo/redo, share, settings, help: check the project's scope-tier or locked-scope document before adding one. Common-app pattern is not a reason. If it is out of scope, say so instead of building it.
- **Debug control reality check** — before adding any debug/seed control, ask whether that state can actually occur in the system. If an earlier step already guarantees the value exists, a toggle to clear it simulates an impossible state — auto-fill it instead. Design debug affordances around the incomplete-input cases, not the complete one.

## --spec flag

When the user invokes `/build --spec` or passes `--spec` alongside a build request:

1. **Read the spec file first** — the `.md` spec file is the source of truth. Parse it before writing any code. Other formats accepted but may lose structure.
2. **Map spec → implementation** — before coding, output a numbered mapping: "1. Section X → component Y, behavior Z". If any spec item is ambiguous or contradictory, list contradictions as a numbered block at this stage (same format as Critic Pass block) and wait for resolution before coding.
3. **Spec gaps** — if the spec is silent on something the build requires, flag it and state your assumption. Do not silently fill gaps.
4. **`--spec` on an edit (not a new build)** — read spec, apply only the diff. Do not rewrite sections that aren't touched by the spec change.
5. **`--spec` without a file path** — ask: "Which spec file should I read?"
6. **Don't record until told** — during iteration, keep decisions in working memory only. Do not patch or write to the spec `.md` until the user explicitly says "record" / "บันทึก". A decision being made is not a signal to persist it.

## Critic Protocol

After every build or major edit, before delivering the file, run one internal critic pass. Switch roles: you are now reviewing someone else's work.

Check these 3 things:

**1. Intent match** — Does the build do exactly what was asked? Not more, not less. Flag scope creep or missing pieces.

**2. Edge cases** — Does the UI break on: empty state, very long text, rapid clicking, small viewport? Note any that aren't handled.

**3. Code quality** — Any: dead code, hardcoded magic numbers without comment, JS that will silently fail, CSS that will break on Safari/Firefox? Note anything that would cause a dev to wince.

**Format the critic output as a compact numbered block before the file:**
```
--- Critic Pass ---
✅ Intent: [one line confirming match, or flag if off]
⚠️  Edge cases: [numbered issues, or "none found"]
⚠️  Code: [numbered issues, or "clean"]
---
Fix before delivering? → yes / skip / fix [numbers] (e.g. "fix 1, 3")
```

**After "fix [numbers]":** apply fixes, then re-run Critic **on the fixed items only** (not a full pass), then deliver.

If no issues: deliver the file directly with the critic block showing all ✅.

**Skip Critic:** `/build --no-critic` or "just give me the file" → skip entirely.

## Execution rules

### While editing

- **Map before touching** — read and understand full file structure (DOM hierarchy, stacking contexts, coordinate systems) before writing any code.
- **Scope match** — edits must match request scope exactly. Don't refactor what wasn't asked to change.
- **Symptom-vs-root check** — when a correction targets a layout symptom on one screen (frame, spacing, wrapper), check whether a shared structural assumption (device frame, app-shell, wrapper) is the real cause before patching that screen alone.
- **Shared component sync** — when creating or changing a shared component (any repeated pattern — card, carousel, selector, dialog, or whatever this project repeats), grep the whole file for every old markup instance and replace all of them in the same pass — not just the new call site. Then tell the user exactly which locations were updated. A new component that isn't applied everywhere the old markup lived is an unfinished edit. Default to a shared component whenever a pattern appears (or will appear) more than once; when applying any principle or fix, apply it to every instance in the file by default and say so — do not wait to be asked to generalize.
- **Breakpoint propagation** — a layout change at one breakpoint must be carried through every other breakpoint in the SAME pass. Never leave the other side on the earlier draft and wait to be told. Name each breakpoint you updated.
- **State-derived rendering** — every element drawn on a canvas/stage must derive from the state that controls it. Never hardcode a child element inside its parent's markup: it will survive after its controlling state is turned off. Also pick the element type from its role, not from where it sits — a keyboard-hint label in a flex row is a `span`, not a `button`.
- **Decision-to-plan sync** — when a decision reached in conversation supersedes an entry in the project's plan/roadmap file, patch that entry in the same pass, before the session ends. Updating the prototype and the SPEC is not enough: the plan file is what the next session reads first, so a stale entry there re-asserts the version that was abandoned. This is the doc-to-doc sibling of the rule below, which only covers a value changed in *code*.
- **Doc-value sync after any rule change** — when changing a rule value in code (size, count, duration, ordering), grep the old value *and its unit* across every doc file in the module before commit — do not only edit the heading you just wrote. The only surviving instances of the old value are in text explaining how it was previously wrong.
- **Detected-vs-editable state split** — auto-detected/system-reported values are immutable state, stored separately from user-editable state. UI shows the detected value locked (with a reset link); edits never mutate the reported detection.
- **Column wrapper over per-child centering** — center a stack by wrapping it in one column container; never rely on `.content > *` per-child margin/width centering (drifts, header bleed-through).
- **Reuse-before-create default** — when adding or moving any UI element, reuse or move the existing component (pick whichever is the better base) instead of building new. Applies especially to result pages, callouts, dialogs, and card art. If a new element is genuinely needed, ask first before building it.
- **Multi-surface sync scope check** — before propagating a change across two surfaces (e.g. a screen and a dialog that mirror each other), confirm scope first: don't assume both need identical treatment. Avoid over-restoring an element the user removed from one surface but not the other.
- **Tag-pair edit safety** — when editing the inner content of an HTML element, include the container's opening AND closing tag in both the old and new strings so a closing tag can't be dropped. After any structural edit, grep-count paired tags (`<div>` vs `</div>`, etc.) before delivering.
- **CSS class-match check** — after any HTML/CSS edit, grep every `class=` token used in markup against the CSS ruleset to confirm each has a matching rule. A class typo (e.g. mismatched state class names) is a shipped visual bug that div-balance won't catch.
- **No runtime crutch for static bugs** — diagnose layout/CSS bugs by reading the markup and CSS directly (parent chain, containing block, intrinsic sizing) before considering any headless browser, screenshot tool, or new dependency. Installing a runtime to observe a bug that is readable in the source is a detour, not a step. If direct reading genuinely can't settle it, ask the user to check in their browser instead.
- **Shared-refactor retest scope** — when a later change extracts or generalizes code that an earlier subsystem already used (shared helpers, a common registry, a promoted utility), name every earlier subsystem the refactor reached backwards into and retest those specifically. Build-time testing of a subsystem stops being valid the moment a shared extraction edits its code path. Retest only what the refactor touched — not a full regression pass.
- **Constraint hit** — if the requested approach has a hard constraint, state it and offer alternatives. Don't silently work around it.
- **Model Gate first** — do not issue the first Edit/TaskCreate call until you have stated: [task class] · [current model] · [match/mismatch → action]. Multi-subsystem builds classify as heavy even when an existing in-file pattern can be templated.
- **No subagent delegation** — never delegate edits to a subagent: single-file prototype edits are context-coupled (a subagent re-pays the whole file as context and loses session decisions). Model choice happens at session level instead: recommend once — Opus/Fable-class for multi-flow ports or large writes, Sonnet for mechanical single-component edits — then proceed. Because this skill forbids subagent delegation, a Model Gate `mismatch` here resolves by stopping and asking the user to switch model, not by spawning — the subagent fallback does not apply to this skill.

### Before delivering

- **Interaction-state checklist (drag/interactive components)** — all four must pass: (a) `user-select: none` during drag; (b) pointer-events pass-through — occluders/overlays must not block input; (c) hitboxes not covered by higher z-index layers; (d) reset transient VFX (glow, committed state) at the end of every cycle so nothing leaks across iterations; (e) input/drag handlers of a slider or range control must never move, re-insert, or re-create their own DOM node mid-gesture — DOM moves kill native drag; re-render around the control, not through it; (f) any draggable/movable floating UI stores position as viewport fractions (0-1) with re-clamp on resize — never absolute px.
- **Tap-vs-drag guard** — every drag-scroll or draggable surface gets a guard: capture and suppress the click if the pointer moved more than ~6px. Apply to all drag surfaces in the file, not just the one being edited.
- **Native control containment** — a native `<select>`/`<input>` sizes from its own intrinsic content and will escape a parent's `overflow` rule. Give it the same wrapping section container its siblings use, plus an explicit `max-width:100%` on the control itself. A parent overflow rule alone does not hold it.
- **OS theme on native controls** — native `select`/`input`/`option` must respect the OS theme: set `color-scheme: light dark` on `:root`; never hardcode a dark control background. Verify once in the opposite OS theme before calling it done.
- **In-file changelog ordering** — oldest version first, newest last. Attribution/credit lines carry no version tag and sit at the bottom. Never assign a new version number to pre-existing baseline work — the baseline is the earliest version.
- **No meta-notes in the artifact** — never write internal problem-solving notes, root-cause explanations, or retro context as comments inside a deliverable file. Keep them in memory only. Minimal functional comments (`ponytail:` intent markers, non-obvious behavior) are fine.
- **Deliverable copy hygiene scan** — before delivering, grep the file's user-facing Thai copy for `—` and CJK leaks (pordee pre-send scan applies to prototype copy too). Any `—` in Thai UI text becomes `-` or a rewritten sentence. This is a deterministic grep, not a judgment call.
- **Category signal coverage** — a visual signal distinguishing item types must cover every part of the element (fill, border, status dot; default *and* active states), not just a 3px edge stripe while every active fill stays the same neutral accent. The larger color area wins and swallows the signal.
- **Headless smoke gate** — any file carrying JS logic must pass a jsdom smoke run before commit (`node --check` cannot see TDZ or load-order errors). Fail = do not deliver.
- **Delivery stamp** — every HTML prototype handoff ends with the commit hash + `hard reload (Cmd+Shift+R)`, from the first round — not after the user reports seeing stale output.
- **End-of-feature i18n audit** — after adding any new strings, sweep all `t()`/`data-i18n` usage across the whole file in one pass and confirm every key exists in the translation table, before declaring the feature done. Don't wait for the user to catch untranslated spots one by one.

### Failure handling

- **2 failed iterations** — if two attempts at the same problem both fail, stop. Present options explicitly — don't attempt a third.
- **Large single-file write (~80k+ chars)** — compose the file in one pass from material already in context; do not re-read large source files mid-compose. If source + carried-over context is too large to compose in one pass, stop and produce a handoff brief instead of retrying the write. A write that loops and resets is the signature of context exhaustion, not a tool bug.
- **File location vs sandbox** — use the Write/Read/Edit tools for any file under a project or memory directory. The bash sandbox only mounts `outputs/` and `uploads/`, so `cp`/`rm`/`ls` on project or memory paths will fail. Reserve bash file ops for files inside the mounted outputs/uploads dirs; don't retry a failing bash path expecting it to mount.

### Session-handoff doc (multi-session builds)

**Plan-label reconciliation** — when a session's actual work diverges from what the project's plan/roadmap file names for that step (pivot, re-sequence, substitution), say so in the same message and offer to amend the plan file. Never carry a step's original label forward over changed work: a step marked done must mean what the plan file says it means, or the plan file gets updated.

When context runs heavy (rising error rate, slow composes) or the build will continue in another session, write `SESSION-HANDOFF.md` in the project folder before stopping. Next session starts with "continue ตาม SESSION-HANDOFF.md". Template:

```markdown
# Session Handoff — <project> · <date>
## Architecture
<file(s), page structure, state model — 3-6 lines>
## Shared components
<name → what it does → where used>
## Done this session
<flow-level list, not diffs>
## Remaining work
<ordered, most-blocked first>
## Open questions
<OQ needing user decision — bundle into one question next session>
## Gotchas
<anything that bit us: quirks, guards, do-not-touch zones>
```

Keep it under ~60 lines — it's a boot loader, not documentation. Overwrite the previous handoff; git history keeps old ones.
