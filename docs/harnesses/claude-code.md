# Claude Code

```
/plugin marketplace add https://github.com/ChanatSinp/dev-helper-toolkits.git
```

(Update the URL above if the repo is renamed.)

Then install any plugin from the catalog, e.g.:

```
/plugin install development-pipeline@dev-helper-toolkits
```

Claude Code auto-discovers a plugin's `agents/` and `skills/` directories from its `.claude-plugin/plugin.json` manifest.

## Without the marketplace

If a project isn't using the Claude Code plugin marketplace, copy the skill manually under `.claude/skills/`. For a plugin with sub-agents, you lose the dispatch (no `agents/` directory to copy alongside it), so it falls back to the same inline, one-stage-at-a-time behavior Codex and Cursor use:

```
cp -r plugins/<plugin-name>/skills/<skill-name> <your-project>/.claude/skills/<skill-name>
```
