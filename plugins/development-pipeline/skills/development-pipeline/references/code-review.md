# Code review

Read before running an opted-in code review or re-review. Part of the orchestrator rules in `SKILL.md`; "sensitive areas" and the model table are defined there.

- **Review first.** Alongside other post-implementation stages, code review (dispatched or inline) and its fix/re-review loop (`SKILL.md` step 6) run first, to completion; the remaining opted-in stages then run as one batch against the final code.
- **Review inline yourself** when the change touches at most 2 files, adds no new module or directory, and touches no sensitive area: read `../../agents/code-reviewer.md` (relative to the skill's directory) first, then read the diff, apply its methodology and severity scale, and write the same `.claude/temp/code-review.md`. Otherwise **dispatch code-reviewer**, model per the `SKILL.md` table.
- **Its brief carries only** the changed-file list, the `plan.md` Context Pack path (when a plan exists; otherwise the project's `CLAUDE.md` commands), and the conventions file(s); it reads the changed files and their direct callees/callers, never the wider repo. A re-review follows the tier of the review it re-checks — unless the fix round's files fail the inline gate above, then dispatch code-reviewer — and its brief adds the pre-fix snapshot and the selected finding IDs (`references/fix-rounds.md`).
- **Check the report is from this run.** After any dispatched review, confirm `.claude/temp/code-review.md` is current — its heading time and Summary name this change — before reading or routing a finding from it; send it back to code-reviewer if it is stale.
