# Gemini CLI (no plugin system)

This runtime reads `SKILL.md` files directly from a project's `.agents/skills/` convention but has no marketplace or plugin manifest to install from. Copy the skill in manually:

```
cp -r plugins/<plugin-name>/skills/<skill-name> <your-project>/.agents/skills/<skill-name>
```

If the plugin ships `agents/`, copy those files beside the skills directory, where its skill looks for stage definitions (`../../agents/` from the skill directory):

```
mkdir -p <your-project>/.agents/agents
cp plugins/<plugin-name>/agents/*.md <your-project>/.agents/agents/
```
