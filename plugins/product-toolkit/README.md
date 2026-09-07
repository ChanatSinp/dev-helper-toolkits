# product-toolkit

Product toolkit: user story co-authoring, market/competitor research, interview/scoping prompts, compact Thai mode — installable on Claude Code, Cursor, and Codex CLI from one shared skill set.

## Contents

- **`.claude-plugin/plugin.json`** — Claude Code manifest.
- **`.codex-plugin/plugin.json`**, **`.cursor-plugin/plugin.json`** — manifests for Codex CLI and Cursor, each pointing at the same `skills/` directory as Claude Code.
- **`.antigravity-plugin/plugin.json`** — minimal manifest for Antigravity, copied out (undotted) alongside `skills/` on install rather than referenced in place.
- **`skills/`** — one harness-agnostic `SKILL.md` per skill, written to run on any runtime that reads `SKILL.md` (no sub-agent dispatch assumed).
- Skills: `grill-me` (interview/pressure-test), `pordee` (compact Thai mode), `designproduct-intelligence` (market/competitor research), `product-doc-coauthor` (user story co-authoring).

## Install

**Claude Code** — distributed via the [dev-helper-toolkits](../../README.md) marketplace:

```
/plugin marketplace add https://github.com/ChanatSinp/dev-helper-toolkits.git
/plugin install product-toolkit@dev-helper-toolkits
```

Or reference `plugins/product-toolkit/` directly as a local plugin directory in your Claude Code settings.

**Cursor** — add this repo as a team marketplace (see the [root README](../../README.md#cursor)), then install `product-toolkit` from the Plugins panel. Runs the same skills as Claude Code.

**Codex CLI** — `codex plugin marketplace add <this-repo>`, then `/plugins` to install. Runs the same skills as Claude Code.

**Antigravity** — has a real plugin system but no marketplace; install by copying the plugin out flattened (see the [root README](../../README.md#antigravity)):

```
mkdir -p <your-project>/.agents/plugins/product-toolkit
cp -r plugins/product-toolkit/skills <your-project>/.agents/plugins/product-toolkit/skills
cp plugins/product-toolkit/.antigravity-plugin/plugin.json <your-project>/.agents/plugins/product-toolkit/plugin.json
```

**Any other `SKILL.md`-reading runtime** (Gemini CLI, or standalone Claude Code without the marketplace) — copy the relevant `skills/<skill-name>/` into that project's own skills convention directory (see the [root README](../../README.md#gemini-cli-no-plugin-system)).
