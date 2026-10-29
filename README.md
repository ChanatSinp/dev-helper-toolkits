# dev-helper-toolkits

BOON's catalog of agent plugins, distributed as a marketplace to Claude Code and Cursor, installable directly by Codex CLI, manually placeable as a real plugin for Antigravity — plus a flatten-copy path for Kiro (custom sub-agents + steering) and a manual-copy path for Gemini CLI, which only reads the open `SKILL.md` format with no plugin system of its own.

Each plugin is self-contained: it carries one manifest per harness (`.claude-plugin/plugin.json`, `.codex-plugin/plugin.json`, `.cursor-plugin/plugin.json`, `.antigravity-plugin/plugin.json`, `.kiro-plugin/plugin.json`) plus a single `skills/` directory those manifests point at (Antigravity discovers `skills/` by convention alongside its manifest rather than a pointer field, but the directory is the same one). Skills are written harness-agnostic — they don't assume sub-agent dispatch — so the same file works whether the plugin is running under Claude Code, Cursor, Codex CLI, Antigravity, or Kiro. A plugin that also ships Claude Code sub-agents (`agents/`) uses them opportunistically: dispatch them where sub-agent dispatch exists (Claude Code and Kiro), otherwise run every stage inline in the same session.

## Plugins in this catalog

- **[development-pipeline](plugins/development-pipeline/README.md)** — a full delivery pipeline of specialized sub-agents plus a skill that orchestrates them from requirement to shipped, verified work.
  ```
  /plugin install development-pipeline@dev-helper-toolkits
  ```

The `/plugin install` command above is Claude Code's; each harness has its own install mechanism — see below.

## Installing per harness

Install and setup steps are harness-specific and kept out of this file:

- [Claude Code](docs/harnesses/claude-code.md) — plugin marketplace add, or manual `.claude/skills/` copy.
- [Cursor](docs/harnesses/cursor.md) — team marketplace import.
- [Codex CLI](docs/harnesses/codex-cli.md) — `codex plugin marketplace add`.
- [Antigravity](docs/harnesses/antigravity.md) — manual manifest-flattening copy into a discovery directory.
- [Kiro](docs/harnesses/kiro.md) — `scripts/install-kiro.sh` flattens the skill into `.kiro/steering/` and the agents into `.kiro/agents/` custom sub-agents.
- [Gemini CLI](docs/harnesses/gemini-cli.md) — no plugin system; manual `SKILL.md` copy only.

## Contributing

See [Adding a new plugin to this catalog](docs/adding-a-plugin.md) for the required manifests, directory layout, and marketplace registration steps.
