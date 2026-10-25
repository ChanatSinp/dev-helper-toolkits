# Grill-me — verify the requirement and gather what is missing

Read when `SKILL.md` Sizing sends you here. Adapted from mattpocock/skills `grill-me` and `wayfinder`. You run it yourself, in this conversation, before any stage is dispatched; it is never delegated. It fixes scope and intent only — solution-architect still owns the detailed functional elicitation.

## When it runs

Whenever the user hands you a requirement and checking it shows you cannot brief a stage without guessing: an unstated behaviour, an undefined actor or state, two sources that disagree, a success criterion you cannot test, or a one-line ask for design-heavy work. Skip it when the requirement is already specific enough to brief from, and for a trivial fix. Stop when the tree resolves; never manufacture questions to keep going.

## Pre-flight — measure, then ask (before every question)

A question whose answer is already in the project wastes the user's turn and prices options from a guess.

1. **Does a document already decide this?** Check `CLAUDE.md`, `.claude/design-plan.md`, `.claude/docs/`, `.claude/api/`, the request itself. Quote the deciding sentence verbatim; never paraphrase a scope boundary — "out of scope" and "remove it" are different instructions.
2. **Does the code already model it?** Look for a sibling implementation, an existing endpoint, a schema column, a config key before asking how something should work or what it would cost. Read the code the new work will reuse or extend — an auth wrapper, a shared handler, a config loader — for defects it would inherit, and raise any as a question.
3. **Can the claim become a number?** If a question involves size, volume, latency, or cost, measure it (row counts, file sizes, existing limits) and put the number in the question.

"Read, don't ask" is not enough: measure, then ask.

## Engine

- **One question at a time.** Walk the decision tree in dependency order — resolve what others hang off first. Wait for each answer.
- **Recommend an answer.** A real fork gets `A / B / C` with one trade-off each, the recommended one first; an obvious best gets a single pick the user can approve. Use `AskUserQuestion` for forks, a plain question otherwise.
- **Options must differ in work performed, not in framing.** State what each option does *not* build; two options that bottom out in the same implementation are one option — collapse them.
- **Hunt contradictions between sources.** When a request, a design document, an upstream API contract, and the code govern one effort, the best questions are where they disagree. Surface the conflict before proposing anything.
- **Prioritise what breaks late:** the primary flow and its forks, the unhappy path, empty / zero / maximum inputs, permissions and who may do it, concurrency and retries, money and persistence consequences, migration of existing data, and how success will be verified.
- **Open-suggest, at most one per turn.** Mark a pattern, edge case, or gap the user may not have reached for as `suggest:` — an offer, not a correction — and check it does not describe behaviour from a branch you claimed to avoid.
- **No answer yet, don't stall.** On "not sure", offer two or three concrete directions to react to.
- **Push back once, then follow their call.** Flag a risky choice once with the reason; if the user holds, record it and move on.
- **A safeguard whose reason expired is relocated, not deleted.** Ask what other risk it was covering and propose moving it there.
- **Split by job, not by material** when one label covers items with different purposes.

## Modes

- **Live (default):** the interview above, one question per turn.
- **Batch:** when no one can answer now (autonomous run) or the user must relay the questions to a client or teammate, write the questions to `.claude/temp/grill-questions.md` instead — pre-partitioned into **Blocking** (changes structure, contracts, or data model; work on that area cannot start) and **Non-blocking** (can be carried as a stated assumption), blocking first and grouped by area, with the areas that are unblocked named. Each question says why it matters. Write it in plain language for whoever answers — no internal IDs, no spec jargon. Never hand over a flat, unranked list.
- **Map:** when the effort is too big for one sitting, chart it in `.claude/temp/grill-map.md` before grilling — `Destination` (what "done deciding" looks like), `Decisions so far` (one line each), `Fog` (questions you can feel coming but cannot phrase yet; the test is whether you can *state* the question, not answer it), `Out of scope`. Resolve one decision per sitting, graduate the fog each answer sharpens, and stop when nothing is left to decide. Plan, don't build.

## End

Close with a compact brief: decisions made, items deferred as stated assumptions, and accepted suggestions. Write it as the request brief for the next stage and list the questions already answered with their answers, so solution-architect or implementation-planner does not re-ask them. Deliver it in the dispatch brief, not as a document of its own; the working files above are `.claude/temp/` intermediates and follow its cleanup.
