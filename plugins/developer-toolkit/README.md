# developer-toolkit

Developer toolkit: dev handoff specs/storybook, design QA reference, single-file HTML prototype build protocol, scoping interview prompts, compact Thai mode — packaged separately per harness.

## Contents

- **`.claude-plugin/plugin.json`** — Claude Code manifest.
- **`.codex-plugin/plugin.json`**, **`.cursor-plugin/plugin.json`** — manifests for Codex CLI and Cursor, each pointing at the same `skills/` directory as Claude Code.
- **`skills/`** — one harness-agnostic `SKILL.md` per skill, written to run on any runtime that reads `SKILL.md` (no sub-agent dispatch assumed).
- Skills: `grill-me` (interview/pressure-test), `pordee` (compact Thai mode), `design-qa` (structured design audit), `design-handoff` (dev handoff spec/storybook), `prototype-build` (single-file HTML prototype build protocol).

## Install

**Claude Code** — distributed via the [claude-code-plugins](../../README.md) marketplace:

```
/plugin marketplace add https://github.com/ChanatSinp/claude-code-plugins.git
/plugin install developer-toolkit@claude-code-plugins
```

Or reference `plugins/developer-toolkit/` directly as a local plugin directory in your Claude Code settings.

**Cursor** — add this repo as a team marketplace (see the [root README](../../README.md#cursor)), then install `developer-toolkit` from the Plugins panel. Runs the same skills as Claude Code.

**Codex CLI** — `codex plugin marketplace add <this-repo>`, then `/plugins` to install. Runs the same skills as Claude Code.

**Any other `SKILL.md`-reading runtime** (Gemini CLI, Antigravity, or standalone Claude Code without the marketplace) — copy the relevant `skills/<skill-name>/` into that project's own skills convention directory (see the [root README](../../README.md#gemini-cli-antigravity-no-plugin-system)).
