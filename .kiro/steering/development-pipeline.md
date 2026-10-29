---
inclusion: auto
name: development-pipeline
description: Use when turning a requirement into shipped, verified work through a staged delivery pipeline — requirements/design, execution planning, implementation with opt-in unit tests, and opt-in technical-test, code-review, and API-documentation stages. Covers feature requests, refactors, bug fixes (including unknown-cause bugs), API work, and any change that needs upfront design or planning before code. Establishes how to size the work, which sub-agent owns each stage, the order stages run in, and how to verify each deliverable before moving on.
---

# Delivery pipeline (Kiro binding)

This steering file makes the `development-pipeline` skill run inside Kiro. The full, harness-agnostic skill — sizing rules, stage sequencing, delivery rules, and Git conventions — is the body below. Read it as your operating manual. This header only binds its abstract stages to Kiro's concrete features.

## How the skill maps onto Kiro

- **Stages are Kiro sub-agents.** Kiro has real sub-agent dispatch, so run the pipeline the way the skill's "Claude Code" path describes: dispatch one sub-agent per stage with `invoke_sub_agent`, not inline. The eight agents live in `.kiro/agents/` and are invoked by name:

  | Skill stage (Agent column) | Kiro sub-agent to dispatch |
  |---|---|
  | solution-architect | `solution-architect` |
  | implementation-planner | `implementation-planner` |
  | plan-driven-implementer | `plan-driven-implementer` |
  | technical-tester | `technical-tester` |
  | code-reviewer | `code-reviewer` |
  | document-reader | `document-reader` |
  | api-specs-writer | `api-specs-writer` |
  | api-bruno-writer | `api-bruno-writer` |

- **"Continue an agent" (`SendMessage`) → re-dispatch with carried context.** Kiro sub-agents run with isolated context and return a result; there is no live resume. When the skill says to continue an agent with answers or rulings, dispatch that same agent fresh with a brief that carries the prior answers, rulings, and the paths it already reported — the skill already defines this as the fallback when an agent is no longer available.
- **"Ask the user" (`AskUserQuestion`) → ask in chat.** You are the user's voice. Sub-agents never ask the user directly; when one returns a question, you ask it in the chat and feed the answer back by re-dispatching the agent that asked. The sizing/opt-in question is one message listing its choices; findings are one per turn.
- **The opt-in stages (unit tests, technical-tester, code-reviewer, api-specs-writer, api-bruno-writer, document-reader) are never default.** Ask once, at sizing time, exactly as the skill's "Sizing the work" section defines. An unanswered or empty answer, or an autonomous run with nobody to ask, means none run.
- **State directory stays `.claude/`.** The skill and all eight agents hardcode `.claude/` for working files (`.claude/design-plan.md`, `.claude/temp/`, `verify.log`, the `.gitignore` entries). That is deliberate and portable — keep using `.claude/` under Kiro too; do not relocate it to `.kiro/`.
- **`references/` paths.** The skill body refers to its helper rules as `references/<name>.md` (relative to the skill directory). Under Kiro those files live at `plugins/development-pipeline/skills/development-pipeline/references/<name>.md` in this repo, or wherever the install script placed them in a target project (`.kiro/steering/development-pipeline/references/<name>.md`). When a brief must point a sub-agent at a reference file (code conventions, design patterns, cdk, unit-tests), pass its absolute path. Read the reference files from whichever of those two locations exists.
- **Context check.** The skill's Workflow step 1 says to stop at 90% context usage and ask the user to run `/compact`. In Kiro, use the `/compact` slash command; estimate usage from the conversation if the session does not show it, and say it is an estimate.

Everything else in the skill applies as written. When the skill says "on any other runtime, run every stage inline," that branch does NOT apply to Kiro — Kiro dispatches sub-agents, like the Claude Code path.

## Reference rule files

#[[file:plugins/development-pipeline/skills/development-pipeline/references/grill-me.md]]
#[[file:plugins/development-pipeline/skills/development-pipeline/references/fan-out.md]]
#[[file:plugins/development-pipeline/skills/development-pipeline/references/fix-rounds.md]]
#[[file:plugins/development-pipeline/skills/development-pipeline/references/code-review.md]]
#[[file:plugins/development-pipeline/skills/development-pipeline/references/api-contracts.md]]
#[[file:plugins/development-pipeline/skills/development-pipeline/references/version-bump.md]]
#[[file:plugins/development-pipeline/skills/development-pipeline/references/cdk.md]]
#[[file:plugins/development-pipeline/skills/development-pipeline/references/unit-tests.md]]

---

# The skill

#[[file:plugins/development-pipeline/skills/development-pipeline/SKILL.md]]
