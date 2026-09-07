# dev-helper-toolkits

BOON's catalog of agent plugins, distributed as a marketplace to Claude Code and Cursor, installable directly by Codex CLI, manually placeable as a real plugin for Antigravity — plus a manual-copy path for Gemini CLI, which only reads the open `SKILL.md` format with no plugin system of its own.

Each plugin is self-contained: it carries one manifest per harness (`.claude-plugin/plugin.json`, `.codex-plugin/plugin.json`, `.cursor-plugin/plugin.json`, `.antigravity-plugin/plugin.json`) plus a single `skills/` directory all four manifests point at (Antigravity discovers `skills/` by convention alongside its manifest rather than a pointer field, but the directory is the same one). Skills are written harness-agnostic — they don't assume sub-agent dispatch — so the same file works whether the plugin is running under Claude Code, Cursor, Codex CLI, or Antigravity. A plugin that also ships Claude Code sub-agents (`agents/`) uses them opportunistically: dispatch them where sub-agent dispatch exists, otherwise run every stage inline in the same session.

## Plugins in this catalog

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

The `/plugin install` command above is Claude Code's; each harness has its own install mechanism — see below.

## Installing per harness

Install and setup steps are harness-specific and kept out of this file:

- [Claude Code](docs/harnesses/claude-code.md) — plugin marketplace add, or manual `.claude/skills/` copy.
- [Cursor](docs/harnesses/cursor.md) — team marketplace import.
- [Codex CLI](docs/harnesses/codex-cli.md) — `codex plugin marketplace add`.
- [Antigravity](docs/harnesses/antigravity.md) — manual manifest-flattening copy into a discovery directory.
- [Gemini CLI](docs/harnesses/gemini-cli.md) — no plugin system; manual `SKILL.md` copy only.

## Contributing

See [Adding a new plugin to this catalog](docs/adding-a-plugin.md) for the required manifests, directory layout, and marketplace registration steps.
