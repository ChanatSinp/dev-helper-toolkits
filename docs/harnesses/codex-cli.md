# Codex CLI

```
codex plugin marketplace add <this-repo>
```

Codex indexes the plugins listed in [`.codex-plugin/marketplace.json`](../../.codex-plugin/marketplace.json) at the repo root on add. Then launch Codex and run `/plugins` to browse and install a plugin — Codex installs from that entry's `source.path` and reads the plugin's own `.codex-plugin/plugin.json`, which points at the same `skills/`.

For a plugin that ships `agents/`, the skill runs every stage inline and reads each stage's definition from `agents/` (`../../agents/` from the skill directory) when the install places that directory beside `skills/` — not confirmed for Codex's plugin install. If it is missing, copy `plugins/<plugin-name>/agents` next to the installed plugin's `skills/` directory by hand.
