# agent-delivery-pipeline

A Claude Code plugin providing a full delivery pipeline of specialized sub-agents plus a skill that orchestrates them from requirement to shipped, verified work.

## Contents

- **`skills/agent-delivery-pipeline/`** — the orchestration skill: sizing rules, stage sequencing, worktree isolation, API-contract handling, and delivery rules.
- **`agents/`** — nine sub-agents, each owning one stage:
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

This plugin is distributed via the [claude-code-plugins](../../README.md) marketplace:

```
/plugin marketplace add https://github.com/ChanatSinp/claude-plugin-agent-delivery-pipeline.git
/plugin install agent-delivery-pipeline@claude-code-plugins
```

Or reference `plugins/agent-delivery-pipeline/` directly as a local plugin directory in your Claude Code settings.
