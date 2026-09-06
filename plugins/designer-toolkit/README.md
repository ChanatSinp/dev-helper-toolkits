# designer-toolkit

Designer toolkit: prototype building, design QA, dev handoff specs, interview/scoping prompts, compact Thai mode — installable on Claude Code, Cursor, and Codex CLI from one shared skill set.

## Contents

- **`.claude-plugin/plugin.json`** — Claude Code manifest.
- **`.codex-plugin/plugin.json`**, **`.cursor-plugin/plugin.json`** — manifests for Codex CLI and Cursor, each pointing at the same `skills/` directory as Claude Code.
- **`skills/`** — one harness-agnostic `SKILL.md` per skill, written to run on any runtime that reads `SKILL.md` (no sub-agent dispatch assumed).
- Skills: `grill-me` (interview/pressure-test), `pordee` (compact Thai mode), `design-qa` (structured design audit), `design-handoff` (dev handoff spec/storybook), `prototype-build` (single-file HTML prototype build protocol).

## Install

**Claude Code** — distributed via the [dev-helper-toolkits](../../README.md) marketplace:

```
/plugin marketplace add https://github.com/ChanatSinp/dev-helper-toolkits.git
/plugin install designer-toolkit@dev-helper-toolkits
```

Or reference `plugins/designer-toolkit/` directly as a local plugin directory in your Claude Code settings.

**Cursor** — add this repo as a team marketplace (see the [root README](../../README.md#cursor)), then install `designer-toolkit` from the Plugins panel. Runs the same skills as Claude Code.

**Codex CLI** — `codex plugin marketplace add <this-repo>`, then `/plugins` to install. Runs the same skills as Claude Code.

**Any other `SKILL.md`-reading runtime** (Gemini CLI, Antigravity, or standalone Claude Code without the marketplace) — copy the relevant `skills/<skill-name>/` into that project's own skills convention directory (see the [root README](../../README.md#gemini-cli-antigravity-no-plugin-system)).
