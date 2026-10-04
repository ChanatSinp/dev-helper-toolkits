# dev-helper-toolkits

Multi-harness plugin marketplace (Claude Code, Cursor, Codex CLI, Antigravity; Gemini CLI by manual copy). No build, lint, or tests — content is Markdown and JSON.

## Layout
- `plugins/<name>/` — one self-contained plugin: `skills/` (shared by all harnesses), optional `agents/`, `README.md`, and per-harness manifests `.claude-plugin/`, `.codex-plugin/`, `.cursor-plugin/`, `.antigravity-plugin/` (each `plugin.json`).
- Root `.claude-plugin/`, `.codex-plugin/`, `.cursor-plugin/` — marketplace manifests (no version field).
- `docs/` — `adding-a-plugin.md`, `harnesses/`.

## Plugins
- `designer-toolkit` — prototype build, design QA, handoff, interview prompts, compact Thai mode.
- `developer-toolkit` — dev handoff, design QA reference, HTML prototype protocol, interview prompts, compact Thai mode.
- `product-toolkit` — user story co-authoring, market/competitor research, interview prompts, compact Thai mode.
- `qa-toolkit` — test plan/case/UAT generation, design QA, interview prompts, compact Thai mode.
- `development-pipeline` — staged delivery pipeline: orchestrator skill plus nine sub-agents (`agents/`).
  - `skills/development-pipeline/SKILL.md` is the orchestrator skill; implementation-planner tags Context Pack entries `[shared]`/`[WP<n>]` and edits `plan.md` in place for fix rounds.
  - plan-driven-implementer has four modes (Package, Consolidation, Direct fix, Whole-plan) and writes `.claude/temp/verify.log` outside package mode.
  - A version bump touches all four `plugin.json` manifests.
