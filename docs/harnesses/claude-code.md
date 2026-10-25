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

If a project isn't using the Claude Code plugin marketplace, copy the skill manually under `.claude/skills/`:

```
cp -r plugins/<plugin-name>/skills/<skill-name> <your-project>/.claude/skills/<skill-name>
```

For a plugin with sub-agents, also copy its agents into `.claude/agents/`. Claude Code loads them from there as project sub-agents, so the skill can still dispatch them, and it is where the skill looks (`../../agents/` from the skill directory) when it runs a stage inline:

```
mkdir -p <your-project>/.claude/agents
cp plugins/<plugin-name>/agents/*.md <your-project>/.claude/agents/
```
