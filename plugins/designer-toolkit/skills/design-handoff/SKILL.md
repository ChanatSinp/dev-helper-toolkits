---
name: design-handoff
version: "1.3"
updated: 2026-08-06
description: >
  Turn a finished design into developer-ready artifacts, in two modes. spec: a dev handoff
  spec sheet (layout, design tokens, component props/variants/states, responsive breakpoints,
  interactions, edge cases) from a Figma file, screenshot, or existing QA report. storybook:
  component documentation — per-component story files or a single-file HTML component gallery —
  enumerating every variant and state from a design or an existing prototype HTML. Use when a
  design is ready for engineering, or the user says "handoff spec", "ทำ handoff spec",
  "ส่งต่อ dev", "สรุป spec ให้ dev", "ทำ storybook", "component gallery", "document components",
  "รวม component ให้ dev". Downstream of design-qa (reuses its findings); not for session
  handoff docs (that's prototype-build) or user stories (product-doc-coauthor).
---

# Design Handoff

## Activation Notice

When this skill loads, prepend the first response with `📦 design-handoff active` on its own line — only once on activation.

Before the first tool call of a spec/storybook build, state one line: [task class] · [current model] · [match/mismatch → action].

## Detect mode

- **spec** — user wants a handoff spec sheet for dev (default when ambiguous)
- **storybook** — user wants component documentation / a component gallery

## Shared rules (both modes)

- **Input cascade:** Figma (MCP, screenshot-first — request the screenshot before the node tree; large frames time out otherwise) → screenshot → prototype HTML file → text description. State which source was used.
- **Reuse, don't re-read:** if a design-qa audit ran this session, pull its findings (states, edge cases, gaps) directly — never re-read the design for information the audit already extracted.
- **Never invent:** undesigned states, breakpoints, or behaviors are listed as `OQ` items for the designer — not filled in with plausible guesses.
- **Approval gate:** show a summary of what will be exported and wait for user confirmation before writing the final file(s).

## Mode: spec

Output one Markdown spec sheet the developer builds from:

1. **Layout** — structure, spacing, alignment grid
2. **Design tokens** — colors, type scale, radii, shadows. Named tokens where the file defines them; raw values flagged `[hardcoded]`
3. **Components** — props, variants, and the full state set (default / hover / active / disabled / loading / error / empty). Missing states → OQ
4. **Responsive** — behavior per designed breakpoint; undesigned ranges → OQ
5. **Interactions & motion** — trigger → behavior → duration/easing when specified
6. **Edge cases** — from the design-qa audit when available; otherwise a quick pass using design-qa's dimension list

Filename: `handoff-spec-[screen]-[YYYY-MM-DD].md`.

## Mode: storybook

Document components so dev can implement and verify them in isolation. Two output formats — ask which one via AskUserQuestion (bundle with any other open questions):

- **HTML gallery** (default when the project's prototypes are single-file HTML): one self-contained HTML file rendering every component × variant × state in a labeled grid, reusing the prototype's actual CSS/markup so the gallery IS the reference implementation.
- **Storybook CSF files**: one `*.stories.js` per component (CSF3 format) when the dev team runs actual Storybook — only produce this when the user confirms the team uses Storybook.

Per component, cover: every variant, every interaction state, edge-content cases (long text, empty, overflow), and a props/usage note. Source of truth order: prototype HTML (real behavior) > Figma > description.

Filename: `component-gallery-[project]-[YYYY-MM-DD].html` or `stories/` folder.

## Boundaries

- Session-continuity handoff docs (SESSION-HANDOFF.md) belong to prototype-build — not this skill.
- User stories / AC belong to product-doc-coauthor.
- Finding design gaps belongs to design-qa — this skill documents; it audits only as a fallback when no QA report exists.
