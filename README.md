# claude-code-plugins

BOON's catalog of Claude Code plugins, distributed as a single marketplace.

## Add this marketplace

```
/plugin marketplace add https://github.com/ChanatSinp/claude-code-plugins.git
```

(Update the URL above if the repo is renamed.)

## Plugins in this catalog

- **[agent-delivery-pipeline](plugins/agent-delivery-pipeline/README.md)** — a full delivery pipeline of specialized sub-agents plus a skill that orchestrates them from requirement to shipped, verified work.
  ```
  /plugin install agent-delivery-pipeline@claude-code-plugins
  ```

## Adding a new plugin to this catalog

1. Create `plugins/<plugin-name>/` with its own `.claude-plugin/plugin.json`, `agents/`, `skills/`, `commands/` as needed, and a `README.md`.
2. Add an entry for it to `.claude-plugin/marketplace.json`'s `plugins` array, with `"source": {"source": "directory", "path": "./plugins/<plugin-name>"}`.
3. List it above.
