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
- `development-pipeline` — staged delivery pipeline: orchestrator skill plus ten sub-agents (`agents/`).
  - `skills/development-pipeline/SKILL.md` is the orchestrator skill, kept to the always-needed rules; `references/fan-out.md`, `fix-rounds.md`, and `api-contracts.md` hold the conditional ones, each read on a trigger line in the skill; `references/design-patterns/` holds on-request architecture examples (`go-gin-hexagonal.md`), named in a brief only when the user or project asks for the pattern; implementation-planner tags Context Pack entries `[shared]`/`[WP<n>]`, extracts the `wp/` slices from `plan.md` by shell (never re-typed), hands back the dispatch map and commands, and edits `plan.md` in place for fix rounds and for the caller's rulings on its open questions.
  - `agents/` are dispatched on Claude Code and read as inline stage definitions (`../../agents/<stage>.md` from the skill dir) elsewhere, so manual installs copy `agents/` too.
  - cdk-implementer executes Work Packages whose Owner column is `cdk` (AWS CDK infra); synth/diff only, never deploys; a plan mixing `app` and `cdk` always runs through `references/fan-out.md` with consolidation.
  - implementation-planner's in-place fix rounds cover selected review findings, verification failures, and failing technical-test cases (routed like `verify.log` failures, `references/fix-rounds.md`); each round's new behaviour gets a unit target, and unit-test-implementer is continued for it when opted in.
  - implementation-planner dry-runs every `[shared]` command before handback; solution-architect applies rulings exactly as worded (doc-to-code rulings change wording only).
  - plan-driven-implementer has four modes (Package, Consolidation, Direct fix, Whole-plan); direct fix takes selected review findings or failing `verify.log` lines.
  - Evidence logs in `.claude/temp/`: `verify.log` (implementer, outside package mode), `unit-test.log` (unit-test-implementer), `test-results.md` (technical-tester), each with `== <command> exit=<code>` lines and captured by shell redirection, never through an agent's context (a closing `summary:` line is plain, never an `== ` marker); technical-tester keeps one indexed `.claude/testing-plan.md`.
  - unit-test-implementer, technical-tester and code-reviewer never run by default: only when the user names them or selects them in the sizing question; a stale-test fix asks first. Their agent descriptions say so too, to stop proactive dispatch outside the pipeline.
  - code-reviewer stamps its report from `date`; `Not reproduced` is allowed only after trying to start the program with dummy config and local stubs (never for "certain from reading"); re-review re-runs repros against the fixed code, diffing untracked files against their `.claude/temp/pre-fix/` copies.
  - code-reviewer reproduces each suspected bug with a mocked script in `.claude/temp/repro/` (log `<function>.log`, expected vs actual in the finding's `Repro:` line) before reporting; unrunnable ones are marked `Not reproduced: <reason>`. Concurrency and money/balance code gets one repro of its riskiest path even with no suspected bug; a convention-required error check (Go `json.Marshal`) is never a dead-code finding.
  - api-specs-writer writes the API contract only, for developers and AI agents calling the API: no file paths, package layout, handler/struct names, or internal flow. So the skill's staleness check (step 4a) flags `api-specs.md` only when the caller-visible contract changes, never on a pure refactor.
  - technical-tester returns any contradiction between sources, including two parts of the design-plan, never files it as informational; plan rows marked "unit" it skips only when unit tests are opted in, otherwise tests the interface-reachable ones.
  - implementation-planner scopes whole-tree format/lint commands to source dirs, never `.` (which would scan `.claude/temp/repro/`); it never plans `api-specs.md` updates (the staleness check is the orchestrator's).
  - Plain-wording rule: SKILL.md "Write for the reader" and one identical sentence at the end of each agent's handback instruction (result first, everyday terms, IDs only when needed and explained); keep them in sync.
  - Comment style (rare, one short, natural line, no narration/change-log comments) is stated in the implementer, cdk, unit-test, planner and reviewer agents and in each `code-conventions/` file's "Layout and comments" section; keep them in sync. C# additionally requires a `<summary>`/`<param>`/`<returns>` XML doc on every method.
  - A version bump touches all four `plugin.json` manifests.
