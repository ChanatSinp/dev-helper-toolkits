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
  - `skills/development-pipeline/SKILL.md` is the orchestrator skill, kept to the always-needed rules; `references/fan-out.md`, `fix-rounds.md`, and `api-contracts.md` hold the conditional ones, each read on a trigger line in the skill; `references/design-patterns/` holds on-request architecture examples (`go-gin-hexagonal.md`), named in a brief only when the user or project asks for the pattern; implementation-planner tags Context Pack entries `[shared]`/`[WP<n>]`, extracts the `wp/` slices from `plan.md` by shell (never re-typed), hands back the dispatch map and commands, and edits `plan.md` in place for fix rounds and for the caller's rulings on its open questions.
  - `agents/` are dispatched on Claude Code and read as inline stage definitions (`../../agents/<stage>.md` from the skill dir) elsewhere, so manual installs copy `agents/` too.
  - implementation-planner's in-place fix rounds cover selected review findings and verification failures.
  - plan-driven-implementer has four modes (Package, Consolidation, Direct fix, Whole-plan); direct fix takes selected review findings or failing `verify.log` lines.
  - Evidence logs in `.claude/temp/`: `verify.log` (implementer, outside package mode), `unit-test.log` (unit-test-implementer), `test-results.md` (technical-tester), each with `== <command> exit=<code>` lines and captured by shell redirection, never through an agent's context (a closing `summary:` line is plain, never an `== ` marker); technical-tester keeps one indexed `.claude/testing-plan.md`.
  - unit-test-implementer, technical-tester and code-reviewer never run by default: only when the user names them or selects them in the sizing question; a stale-test fix asks first. Their agent descriptions say so too, to stop proactive dispatch outside the pipeline.
  - A version bump touches all four `plugin.json` manifests.
