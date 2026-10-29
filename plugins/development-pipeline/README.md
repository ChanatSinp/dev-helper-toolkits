# development-pipeline

A full delivery pipeline of specialized sub-agents plus a skill that orchestrates them from requirement to shipped, verified work — installable on Claude Code, Cursor, Codex CLI, Antigravity, and Kiro, and by manual copy on Gemini CLI, from one shared skill.

## Contents

- **`.claude-plugin/plugin.json`** — Claude Code manifest.
- **`.codex-plugin/plugin.json`**, **`.cursor-plugin/plugin.json`** — manifests for Codex CLI and Cursor, each pointing at the same `skills/` directory as Claude Code.
- **`.antigravity-plugin/plugin.json`** — minimal manifest for Antigravity, copied out (undotted) alongside `skills/` and `agents/` on install rather than referenced in place.
- **`.kiro-plugin/plugin.json`** — Kiro manifest, pointing at the same `agents/` and `skills/` directories. Kiro runs the pipeline with real sub-agent dispatch (like Claude Code): `scripts/install-kiro.sh` turns the skill into an auto-included steering-file orchestrator and each agent into a `.kiro/agents/*.json` custom sub-agent.
- **`skills/development-pipeline/`** — one harness-agnostic orchestration skill: sizing rules (including a SemVer `vX.Y.Z` project version bump only when the user asks for one), stage sequencing, and delivery rules, with the grill-me, fan-out, fix-round, code-review, version-bump, and API-contract rules in `references/` files it reads only when that situation arises (code conventions and the on-request design-pattern examples, such as `design-patterns/go-gin-hexagonal.md`, live there too). On Claude Code, dispatch the named sub-agent per stage; on any other runtime, run every stage yourself in the same session, one at a time, reading the stage's definition from `agents/` first.
- **`agents/`** — eight stage definitions (the technical-test and code-review agents run only when the user asks for them, never by default), each owning one stage: dispatched as sub-agents by `skills/development-pipeline/` where sub-agent dispatch is available (Claude Code), read by the skill as that stage's instructions (`../../agents/<stage>.md` from the skill directory) on every other runtime:
  - `solution-architect` — functional + technical design (`.claude/design-plan.md`, with a feature index and shared invariants at the top so later stages read only their sections)
  - `implementation-planner` — execution plan (`.claude/temp/plan.md`); for a bug with an unknown cause it reproduces and diagnoses first, recording the root cause in the plan
  - `plan-driven-implementer` — faithful plan execution (product code only), one dispatch for the whole plan, or — only when the user asks — fanned out one dispatch per work package (each reading only its `.claude/temp/wp/` slice, which carries the shared Context Pack entries plus its own package's; `routine` packages on Sonnet) plus a Sonnet consolidation pass that writes the full lint/build/test output to `.claude/temp/verify.log`; small fix rounds — selected code-review findings, or a failing `verify.log` where product code is at fault, or failing technical-test cases — are dispatched directly, larger ones through a "(fix round N)" phase added to the plan
  - AWS CDK infrastructure has no agent of its own: plan-driven-implementer executes `cdk`-owned phases under `references/cdk.md`, in the project's CDK language (TypeScript for a new app); it verifies with `cdk synth` (and `cdk diff` against a non-prod stage when credentials are available), never deploys, bootstraps, or destroys — it hands the deploy commands back
  - Unit tests have no agent or stage of their own: when opted in, plan-driven-implementer writes them for the plan's unit-marked targets in the same pass as the code, under `references/unit-tests.md`, and its `verify.log` runs them (a stale test the change breaks is updated in that pass, or — when unit tests were not opted in — only after the user agrees)
  - `technical-tester` — test plan + execution (opt-in): one `.claude/testing-plan.md` indexed per feature, results in `.claude/temp/test-results.md`
  - `code-reviewer` — correctness/security/edge-case review (opt-in), run with its fix/re-review loop before the other post-implementation stages
  - `document-reader` — distills source documents into `.claude/docs/` summaries (opt-in)
  - `api-specs-writer` — documents this project's own HTTP API contract for developers and AI agents, never its code structure, ending with an API flow and sequence diagram of how the endpoints are called together (opt-in, on Sonnet)
  - `api-bruno-writer` — generates a Bruno collection from the API doc (opt-in, on Sonnet)

## Install

**Claude Code** — distributed via the [dev-helper-toolkits](../../README.md) marketplace:

```
/plugin marketplace add https://github.com/ChanatSinp/dev-helper-toolkits.git
/plugin install development-pipeline@dev-helper-toolkits
```

Or reference `plugins/development-pipeline/` directly as a local plugin directory in your Claude Code settings.

**Cursor** — add this repo as a team marketplace (see the [root README](../../README.md#cursor)), then install `development-pipeline` from the Plugins panel. Runs every stage inline in the same session — no sub-agent dispatch.

**Codex CLI** — `codex plugin marketplace add <this-repo>`, then `/plugins` to install. Runs every stage inline, same as Cursor.

**Antigravity** — has a real plugin system but no marketplace; install by copying the plugin out flattened (see [Antigravity](../../docs/harnesses/antigravity.md)). Runs every stage inline, same as Cursor and Codex CLI — `agents/` is copied too, as the stage definitions the skill reads, not for dispatch:

```
mkdir -p <your-project>/.agents/plugins/development-pipeline
cp -r plugins/development-pipeline/skills <your-project>/.agents/plugins/development-pipeline/skills
cp -r plugins/development-pipeline/agents <your-project>/.agents/plugins/development-pipeline/agents
cp plugins/development-pipeline/.antigravity-plugin/plugin.json <your-project>/.agents/plugins/development-pipeline/plugin.json
```

**Kiro** — has custom sub-agents and steering but no repo-importing marketplace; install with the flatten script (see [Kiro](../../docs/harnesses/kiro.md)). Dispatches each stage as a sub-agent, like Claude Code:

```
scripts/install-kiro.sh <your-project>
```

This writes `.kiro/steering/development-pipeline.md` (the `inclusion: auto` orchestrator) plus its `SKILL.md`, `agents/`, and `references/`, and one `.kiro/agents/<stage>.json` custom sub-agent per stage.

**Any other `SKILL.md`-reading runtime** (Gemini CLI, or standalone Claude Code without the marketplace) — copy `skills/development-pipeline/` into that project's own skills convention directory, and the `agents/*.md` files into an `agents/` directory beside that skills directory, where the skill looks for them (`../../agents/<stage>.md` from the skill directory): `.agents/agents/` for [Gemini CLI](../../docs/harnesses/gemini-cli.md), `.claude/agents/` for [Claude Code](../../docs/harnesses/claude-code.md) — which loads them from there as project sub-agents, so dispatch works.
