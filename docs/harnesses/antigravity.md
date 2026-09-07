# Antigravity

Antigravity has a real plugin system, but no marketplace to install from — a plugin is a directory containing an undotted `plugin.json` at its root, dropped into a discovery directory: project-specific `.agents/plugins/<plugin-name>/`, or global `~/.gemini/config/plugins/<plugin-name>/`.

Since this repo keeps that manifest in `.antigravity-plugin/plugin.json` (matching the other three harnesses' dot-dir convention) rather than at the plugin root, installing means flattening it out on copy:

```
mkdir -p <your-project>/.agents/plugins/<plugin-name>
cp -r plugins/<plugin-name>/skills <your-project>/.agents/plugins/<plugin-name>/skills
cp plugins/<plugin-name>/.antigravity-plugin/plugin.json <your-project>/.agents/plugins/<plugin-name>/plugin.json
```

(Swap the destination for `~/.gemini/config/plugins/<plugin-name>/` to install globally instead.)

Plugins are enabled by default once discovered; toggle with `agy plugin enable|disable <plugin-name>` or from the Antigravity settings UI.

`agents/` (Claude Code sub-agents) has no Antigravity equivalent — the skill runs every stage inline in the same session instead, same as on Cursor and Codex CLI.
