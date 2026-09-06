# claude-code-plugins

BOON's catalog of agent plugins, distributed as a marketplace to Claude Code and Cursor, and installable directly by Codex CLI — plus a manual-copy path for runtimes (Gemini CLI, Antigravity) that only read the open `SKILL.md` format with no plugin system of their own.

Each plugin is self-contained: it carries one manifest per harness (`.claude-plugin/plugin.json`, `.codex-plugin/plugin.json`, `.cursor-plugin/plugin.json`) plus whatever skills/agents that harness can use, instead of harness variants living in a separate tree alongside `plugins/`.

## Claude Code

```
/plugin marketplace add https://github.com/ChanatSinp/claude-code-plugins.git
```

(Update the URL above if the repo is renamed.)

### Plugins in this catalog

- **[agent-delivery-pipeline](plugins/agent-delivery-pipeline/README.md)** — a full delivery pipeline of specialized sub-agents plus a skill that orchestrates them from requirement to shipped, verified work.
  ```
  /plugin install agent-delivery-pipeline@claude-code-plugins
  ```

### Adding a new plugin to this catalog

1. Create `plugins/<plugin-name>/` with:
   - `.claude-plugin/plugin.json` — Claude Code manifest (agents/skills auto-discovered by convention from `agents/`, `skills/` at the plugin root).
   - `.codex-plugin/plugin.json` and `.cursor-plugin/plugin.json` — manifests for those harnesses, each pointing `"skills"` at the shared portable skill (see below).
   - `skills/<skill-name>/SKILL.md` — the Claude Code version, free to assume sub-agent dispatch.
   - `skills-portable/<skill-name>/SKILL.md` — a harness-agnostic rewrite for Codex/Cursor/manual-copy use, run sequentially by the one active agent with no isolated dispatch assumed.
   - `agents/` — Claude-only sub-agent definitions, if the plugin has any.
   - `README.md`.
2. Add an entry for it to `.claude-plugin/marketplace.json`'s `plugins` array, with `"source": {"source": "directory", "path": "./plugins/<plugin-name>"}`. Mirror the same entry into `.cursor-plugin/marketplace.json` at the repo root.
3. List it above.

## Cursor

Add this repository as a team marketplace from **Settings → Plugins → Team Marketplaces → Add Marketplace → Import from Repo**, pointing it at this repo. Cursor indexes the plugins listed in [`.cursor-plugin/marketplace.json`](.cursor-plugin/marketplace.json) on import, then installs each plugin's `.cursor-plugin/plugin.json`, which points at that plugin's `skills-portable/` directory.

## Codex CLI

```
codex plugin marketplace add <this-repo>
```

Then launch Codex and run `/plugins` to browse and install a plugin — Codex reads that plugin's `.codex-plugin/plugin.json`, which points at `skills-portable/`.

## Gemini CLI, Antigravity (no plugin system)

These runtimes read `SKILL.md` files directly from a project's `.agents/skills/` convention but have no marketplace to install from. Copy the portable skill in manually:

```
cp -r plugins/<plugin-name>/skills-portable/<skill-name> <your-project>/.agents/skills/<skill-name>
```

## Claude Code without the marketplace

If a project isn't using the Claude Code plugin marketplace, copy the portable skill the same way instead, under `.claude/skills/` — you lose the sub-agent dispatch the marketplace plugin gives you, falling back to the same sequential-stage skill Codex and Cursor use:

```
cp -r plugins/<plugin-name>/skills-portable/<skill-name> <your-project>/.claude/skills/<skill-name>
```
