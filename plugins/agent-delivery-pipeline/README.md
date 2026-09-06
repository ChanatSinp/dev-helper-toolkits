# agent-delivery-pipeline

A full delivery pipeline of specialized sub-agents plus a skill that orchestrates them from requirement to shipped, verified work — packaged separately per harness.

## Contents

- **`.claude-plugin/plugin.json`** — Claude Code manifest.
- **`.codex-plugin/plugin.json`**, **`.cursor-plugin/plugin.json`** — manifests for Codex CLI and Cursor, each pointing at the same `skills/` directory as Claude Code.
- **`skills/agent-delivery-pipeline/`** — one harness-agnostic orchestration skill: sizing rules, stage sequencing, worktree isolation, API-contract handling, and delivery rules. On Claude Code, dispatch the named sub-agent per stage; on any other runtime, run every stage yourself in the same session, one at a time.
- **`agents/`** — nine sub-agents (Claude Code only, dispatched by `skills/agent-delivery-pipeline/` when sub-agent dispatch is available), each owning one stage:
  - `solution-architect` — functional + technical design (`.claude/design-plan.md`)
  - `implementation-planner` — execution plan (`.claude/temp/plan.md`)
  - `plan-driven-implementer` — faithful plan execution (product code only)
  - `unit-test-implementer` — unit tests (opt-in)
  - `technical-tester` — test plan + execution (opt-in)
  - `code-reviewer` — correctness/security/edge-case review (opt-in)
  - `document-reader` — distills source documents into `.claude/docs/` summaries
  - `api-specs-writer` — documents this project's own HTTP API (opt-in)
  - `api-bruno-writer` — generates a Bruno collection from the API doc (opt-in)

## Install

**Claude Code** — distributed via the [claude-code-plugins](../../README.md) marketplace:

```
/plugin marketplace add https://github.com/ChanatSinp/claude-code-plugins.git
/plugin install agent-delivery-pipeline@claude-code-plugins
```

Or reference `plugins/agent-delivery-pipeline/` directly as a local plugin directory in your Claude Code settings.

**Cursor** — add this repo as a team marketplace (see the [root README](../../README.md#cursor)), then install `agent-delivery-pipeline` from the Plugins panel. Runs every stage inline in the same session — no sub-agent dispatch.

**Codex CLI** — `codex plugin marketplace add <this-repo>`, then `/plugins` to install. Runs every stage inline, same as Cursor.

**Any other `SKILL.md`-reading runtime** (Gemini CLI, Antigravity, or standalone Claude Code without the marketplace) — copy `skills/agent-delivery-pipeline/` into that project's own skills convention directory (see the [root README](../../README.md#gemini-cli-antigravity-no-plugin-system)).
