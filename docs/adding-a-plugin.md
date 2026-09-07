# Adding a new plugin to this catalog

1. Create `plugins/<plugin-name>/` with:
   - `.claude-plugin/plugin.json` — Claude Code manifest (agents/skills auto-discovered by convention from `agents/`, `skills/` at the plugin root).
   - `.codex-plugin/plugin.json` and `.cursor-plugin/plugin.json` — manifests for those harnesses, each pointing `"skills"` at the same `./skills/` directory as Claude Code.
   - `.antigravity-plugin/plugin.json` — minimal manifest (`name` + `description`) for Antigravity. Antigravity has no `"skills"` pointer field; it discovers a plugin's `skills/` by sitting next to an undotted `plugin.json` at the plugin's install root, so this file is copied out — not referenced in place — on install (see [Antigravity](harnesses/antigravity.md)).
   - `skills/<skill-name>/SKILL.md` — one harness-agnostic file per skill: no assumption of sub-agent dispatch, no harness-specific paths beyond naming `.claude/` as an example convention directory. If the plugin has sub-agents, phrase stage ownership as "dispatch the named agent where available, otherwise run the stage yourself."
   - `agents/` — Claude-only sub-agent definitions, if the plugin has any. `skills/` references them by name as the Claude Code binding for a stage; they're inert (auto-discovered but never dispatched) on runtimes without sub-agent support.
   - `README.md`.
2. Add an entry for it to `.claude-plugin/marketplace.json`'s `plugins` array, with `"source": "./plugins/<plugin-name>"`. Mirror the same entry into `.cursor-plugin/marketplace.json` at the repo root (same flat `"source"` string shape), and into `.codex-plugin/marketplace.json` at the repo root using Codex's nested shape: `"source": { "source": "local", "path": "./plugins/<plugin-name>" }`.
3. List it in the catalog table in [`README.md`](../README.md).
