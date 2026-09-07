# dev-helper-toolkits

BOON's catalog of agent plugins, distributed as a marketplace to Claude Code and Cursor, installable directly by Codex CLI, manually placeable as a real plugin for Antigravity — plus a manual-copy path for Gemini CLI, which only reads the open `SKILL.md` format with no plugin system of its own.

Each plugin is self-contained: it carries one manifest per harness (`.claude-plugin/plugin.json`, `.codex-plugin/plugin.json`, `.cursor-plugin/plugin.json`, `.antigravity-plugin/plugin.json`) plus a single `skills/` directory all four manifests point at (Antigravity discovers `skills/` by convention alongside its manifest rather than a pointer field, but the directory is the same one). Skills are written harness-agnostic — they don't assume sub-agent dispatch — so the same file works whether the plugin is running under Claude Code, Cursor, Codex CLI, or Antigravity. A plugin that also ships Claude Code sub-agents (`agents/`) uses them opportunistically: dispatch them where sub-agent dispatch exists, otherwise run every stage inline in the same session.

## Claude Code

```
/plugin marketplace add https://github.com/ChanatSinp/dev-helper-toolkits.git
```

(Update the URL above if the repo is renamed.)

### Plugins in this catalog

- **[development-pipeline](plugins/development-pipeline/README.md)** — a full delivery pipeline of specialized sub-agents plus a skill that orchestrates them from requirement to shipped, verified work.
  ```
  /plugin install development-pipeline@dev-helper-toolkits
  ```
- **[designer-toolkit](plugins/designer-toolkit/README.md)** — prototype building, design QA, dev handoff specs, interview/scoping prompts, compact Thai mode.
  ```
  /plugin install designer-toolkit@dev-helper-toolkits
  ```
- **[developer-toolkit](plugins/developer-toolkit/README.md)** — dev handoff specs/storybook, design QA reference, single-file HTML prototype build protocol, scoping interview prompts, compact Thai mode.
  ```
  /plugin install developer-toolkit@dev-helper-toolkits
  ```
- **[product-toolkit](plugins/product-toolkit/README.md)** — user story co-authoring, market/competitor research, interview/scoping prompts, compact Thai mode.
  ```
  /plugin install product-toolkit@dev-helper-toolkits
  ```
- **[qa-toolkit](plugins/qa-toolkit/README.md)** — test plan/case/UAT generation, design QA audits, interview/scoping prompts, compact Thai mode.
  ```
  /plugin install qa-toolkit@dev-helper-toolkits
  ```

### Adding a new plugin to this catalog

1. Create `plugins/<plugin-name>/` with:
   - `.claude-plugin/plugin.json` — Claude Code manifest (agents/skills auto-discovered by convention from `agents/`, `skills/` at the plugin root).
   - `.codex-plugin/plugin.json` and `.cursor-plugin/plugin.json` — manifests for those harnesses, each pointing `"skills"` at the same `./skills/` directory as Claude Code.
   - `.antigravity-plugin/plugin.json` — minimal manifest (`name` + `description`) for Antigravity. Antigravity has no `"skills"` pointer field; it discovers a plugin's `skills/` by sitting next to an undotted `plugin.json` at the plugin's install root, so this file is copied out — not referenced in place — on install (see the Antigravity section below).
   - `skills/<skill-name>/SKILL.md` — one harness-agnostic file per skill: no assumption of sub-agent dispatch, no harness-specific paths beyond naming `.claude/` as an example convention directory. If the plugin has sub-agents, phrase stage ownership as "dispatch the named agent where available, otherwise run the stage yourself."
   - `agents/` — Claude-only sub-agent definitions, if the plugin has any. `skills/` references them by name as the Claude Code binding for a stage; they're inert (auto-discovered but never dispatched) on runtimes without sub-agent support.
   - `README.md`.
2. Add an entry for it to `.claude-plugin/marketplace.json`'s `plugins` array, with `"source": "./plugins/<plugin-name>"`. Mirror the same entry into `.cursor-plugin/marketplace.json` at the repo root.
3. List it above.

## Cursor

Add this repository as a team marketplace from **Settings → Plugins → Team Marketplaces → Add Marketplace → Import from Repo**, pointing it at this repo. Cursor indexes the plugins listed in [`.cursor-plugin/marketplace.json`](.cursor-plugin/marketplace.json) on import, then installs each plugin's `.cursor-plugin/plugin.json`, which points at that plugin's `skills/` directory.

## Codex CLI

```
codex plugin marketplace add <this-repo>
```

Then launch Codex and run `/plugins` to browse and install a plugin — Codex reads that plugin's `.codex-plugin/plugin.json`, which points at the same `skills/`.

## Antigravity

Antigravity has a real plugin system, but no marketplace to install from — a plugin is a directory containing an undotted `plugin.json` at its root, dropped into a discovery directory: project-specific `.agents/plugins/<plugin-name>/`, or global `~/.gemini/config/plugins/<plugin-name>/`. Since this repo keeps that manifest in `.antigravity-plugin/plugin.json` (matching the other three harnesses' dot-dir convention) rather than at the plugin root, installing means flattening it out on copy:

```
mkdir -p <your-project>/.agents/plugins/<plugin-name>
cp -r plugins/<plugin-name>/skills <your-project>/.agents/plugins/<plugin-name>/skills
cp plugins/<plugin-name>/.antigravity-plugin/plugin.json <your-project>/.agents/plugins/<plugin-name>/plugin.json
```

(Swap the destination for `~/.gemini/config/plugins/<plugin-name>/` to install globally instead.) Plugins are enabled by default once discovered; toggle with `agy plugin enable|disable <plugin-name>` or from the Antigravity settings UI. `agents/` (Claude Code sub-agents) has no Antigravity equivalent — the skill runs every stage inline in the same session instead, same as on Cursor and Codex CLI.

## Gemini CLI (no plugin system)

This runtime reads `SKILL.md` files directly from a project's `.agents/skills/` convention but has no marketplace or plugin manifest to install from. Copy the skill in manually:

```
cp -r plugins/<plugin-name>/skills/<skill-name> <your-project>/.agents/skills/<skill-name>
```

## Claude Code without the marketplace

If a project isn't using the Claude Code plugin marketplace, copy the skill the same way instead, under `.claude/skills/` — for a plugin with sub-agents, you lose the dispatch (no `agents/` directory to copy alongside it), so it falls back to the same inline, one-stage-at-a-time behavior Codex and Cursor use:

```
cp -r plugins/<plugin-name>/skills/<skill-name> <your-project>/.claude/skills/<skill-name>
```
