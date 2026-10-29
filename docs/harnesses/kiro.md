# Kiro

Kiro (the AI IDE built on VS Code) has first-class **custom sub-agents** and **steering files**, but no plugin marketplace that imports an arbitrary git repo. So a plugin maps onto Kiro's own primitives rather than installing as a bundle:

- the plugin's **skill** becomes an auto-included **steering file** (`.kiro/steering/<skill>.md`) that orchestrates the pipeline;
- the plugin's **`agents/`** become Kiro **custom sub-agents** (`.kiro/agents/*.json`), dispatched one per stage — Kiro has real sub-agent dispatch, so the pipeline runs the same per-stage dispatch model as Claude Code, not the inline model Cursor/Codex/Antigravity use;
- the plugin's **`references/`** ride along beside the steering file so its `#[[file:...]]` links and the sub-agent briefs resolve.

## Install (script)

From this repo, flatten the plugin into a project's `.kiro/` (workspace scope) or into `~/.kiro/` (user scope — every Kiro session, every project):

```
scripts/install-kiro.sh <your-project> [plugin-name]   # one project
scripts/install-kiro.sh --global        [plugin-name]   # ~/.kiro, all projects
```

`plugin-name` defaults to `development-pipeline`. The script creates (rooted at `<your-project>/.kiro/` or `~/.kiro/`):

```
.kiro/
  steering/development-pipeline.md              # orchestrator (inclusion: auto)
  steering/development-pipeline/SKILL.md        # the harness-agnostic skill body
  steering/development-pipeline/agents/*.md     # stage definitions (prompt source)
  steering/development-pipeline/references/     # grill-me, fan-out, fix-rounds, cdk, conventions, ...
  agents/*.json                                 # one Kiro custom sub-agent per stage
```

The steering file carries `inclusion: auto` with a `description`, so Kiro pulls it in automatically when a request matches (a delivery/feature/bug/refactor task). You can also invoke it by name as the `#development-pipeline` context key or the `/development-pipeline` slash command.

**User scope vs. workspace scope.** A `--global` install lives in `~/.kiro/` and applies to every session. A project's own `.kiro/` still takes precedence where both define the same agent or steering name, so a workspace can override or pin a version. To update a global install, re-run `--global` after pulling the repo; to remove it, delete `~/.kiro/steering/development-pipeline.md`, `~/.kiro/steering/development-pipeline/`, and `~/.kiro/agents/<stage>.json`.

## Install (manual)

If you only want it in one project and don't want to run the script, copy the four pieces by hand:

```
mkdir -p <your-project>/.kiro/steering/development-pipeline <your-project>/.kiro/agents
cp -r plugins/development-pipeline/skills/development-pipeline/references <your-project>/.kiro/steering/development-pipeline/references
cp -r plugins/development-pipeline/agents                                <your-project>/.kiro/steering/development-pipeline/agents
cp    plugins/development-pipeline/skills/development-pipeline/SKILL.md   <your-project>/.kiro/steering/development-pipeline/SKILL.md
```

Then add the orchestrator steering file and one agent JSON per stage. The committed `.kiro/steering/development-pipeline.md` and `.kiro/agents/*.json` in this repo are working examples — copy them and rewrite the `#[[file:...]]` and `prompt` `file://` paths to the installed layout (the install script does this rewrite for you, so prefer the script).

## How it runs

- **Stages are sub-agents.** The orchestrator dispatches `solution-architect`, `implementation-planner`, `plan-driven-implementer`, `technical-tester`, `code-reviewer`, `document-reader`, `api-specs-writer`, and `api-bruno-writer` with `invoke_sub_agent`, following the skill's sizing and sequencing rules.
- **"Continue an agent" means re-dispatch with carried context.** Kiro sub-agents return a result and don't resume live, so when the skill says to continue an agent with answers or rulings, the orchestrator re-dispatches that agent with a brief carrying the prior answers and the paths it already produced — the fallback the skill already defines.
- **The opt-in stages stay opt-in.** Unit tests, technical-tester, code-reviewer, api-specs-writer, api-bruno-writer, and document-reader run only when the user asks at sizing time.
- **State directory is `.claude/`.** The skill and agents keep their working files under `.claude/` (`design-plan.md`, `temp/`, `verify.log`) on every harness, Kiro included — the repo's root `.gitignore` already ignores `**/.claude/temp/` and `**/.claude/settings*.json`.

`agents/` under Kiro is dispatched, not read inline — unlike Cursor, Codex CLI, and Antigravity, where the same stage definitions are read inline because those runtimes have no sub-agent dispatch.
