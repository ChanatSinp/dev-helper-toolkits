# dev-helper-toolkits

Multi-harness plugin marketplace (Claude Code, Cursor, Codex CLI, Antigravity; Gemini CLI by manual copy). No build or lint — content is Markdown and JSON. `scripts/check-dev-pipeline.sh` runs development-pipeline's mechanical checks (manifest versions, synced sentences, reference links, the planner's slice extraction); run it after any edit to that plugin.

## Layout
- `plugins/<name>/` — one self-contained plugin: `skills/` (shared by all harnesses), optional `agents/`, `README.md`, and per-harness manifests `.claude-plugin/`, `.codex-plugin/`, `.cursor-plugin/`, `.antigravity-plugin/` (each `plugin.json`).
- Root `.claude-plugin/`, `.codex-plugin/`, `.cursor-plugin/` — marketplace manifests (no version field).
- `docs/` — `adding-a-plugin.md`, `harnesses/`.

## Plugins
- `development-pipeline` — staged delivery pipeline: orchestrator skill plus eight sub-agents (`agents/`); behaviour is described in `plugins/development-pipeline/README.md`, and the files themselves are the rules.
  - `skills/development-pipeline/SKILL.md` holds the always-needed rules, including the one model-per-dispatch table and the definition of sensitive areas; `references/` holds the conditional ones (`fan-out.md`, `fix-rounds.md`, `code-review.md`, `api-contracts.md`, `cdk.md` — AWS CDK work, `unit-tests.md` — unit tests written in the implementation pass; both executed by plan-driven-implementer), each read on a trigger line, plus `code-conventions/` and on-request `design-patterns/`.
  - `agents/` are dispatched on Claude Code and read as inline stage definitions (`../../agents/<stage>.md` from the skill dir) elsewhere, so manual installs copy `agents/` too.
  - Keep in sync: the plain-wording sentence at the end of every agent's handback instruction (mirrors SKILL.md "Write for the reader"), and the comment-style line in the implementer, planner and reviewer agents and each `code-conventions/` file (C# also requires XML docs on every method; `cocos-creator.md` pairs with `javascript-typescript.md`).
  - A version bump touches all four `plugin.json` manifests.
