# Codex CLI

```
codex plugin marketplace add <this-repo>
```

Codex indexes the plugins listed in [`.codex-plugin/marketplace.json`](../../.codex-plugin/marketplace.json) at the repo root on add. Then launch Codex and run `/plugins` to browse and install a plugin — Codex installs from that entry's `source.path` and reads the plugin's own `.codex-plugin/plugin.json`, which points at the same `skills/`.
