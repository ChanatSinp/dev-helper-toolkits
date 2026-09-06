---
name: agent-delivery-pipeline
description: Use when turning a requirement into shipped, verified work through a staged delivery pipeline (requirements/design, execution planning, implementation, and opt-in test/review/doc stages). Establishes how to size the work, what each stage owns, the order stages run in, and how to verify each deliverable before moving on. Harness-agnostic: written for any agent runtime that reads SKILL.md (Codex CLI, Cursor, Gemini CLI, Antigravity), without assuming isolated sub-agent dispatch.
---

# Delivery pipeline (harness-agnostic)

This is a portable rewrite of the `agent-delivery-pipeline` Claude Code plugin for runtimes that don't have Claude Code's sub-agent dispatch tool (separate context + restricted toolset per agent). If your runtime *does* support spawning isolated sub-agents or custom personas, prefer doing so per stage, keeping this file as the shared brief. If it doesn't, perform every stage yourself, in the same session, one at a time, clearly labeling which stage you're in — never blend stages together.

Artifacts live under this harness's own convention directory at the project root — `.codex/` for Codex CLI, `.cursor/` for Cursor, `.agents/` for Gemini CLI/Antigravity, or equivalent — kept in sync with wherever the harness already writes its own state/config. The examples below use `<state-dir>/` as a stand-in for that directory:

```
<state-dir>/
  design-plan.md      # functional + technical design (tracked deliverable)
  testing-plan.md      # test plan + results (tracked deliverable)
  temp/
    plan.md            # execution plan (intermediate, gitignored)
    code-review.md      # review findings (intermediate, gitignored)
  docs/                # distilled source documents, one subfolder per subject
  api/
    api-specs.md        # this project's own HTTP API, documented from code
    <service>/           # vendored/summarized contract for an upstream service
    bruno/                # generated Bruno collection (opt-in)
```

## The stages

| Stage | Owns | Deliverable |
|---|---|---|
| Requirements & design | Elicit requirements, then produce functional spec (*what*) and technical design (*how*): architecture, schema, contracts, migration | `<state-dir>/design-plan.md` |
| Execution planning | Turn the design into files, phases, edge cases | `<state-dir>/temp/plan.md` |
| Implementation | Faithful execution of the plan — product/application code only, never test functions | code changes |
| Unit testing (opt-in) | Unit test functions, following the actual implementation | test code changes |
| Technical testing (opt-in) | Test plan + execution with evidence | `<state-dir>/testing-plan.md`, results |
| Code review (opt-in) | Correctness/security/edge-case review, findings only — never a plan | `<state-dir>/temp/code-review.md` |
| Document distillation (opt-in) | Distills a source document (API spec, PDF, Word doc, Postman collection) into a reference summary; if it's a prose-only upstream API contract, also write the house `api-specs.md` shape | one markdown file per document under `<state-dir>/docs/`, plus `<state-dir>/api/<service>/api-specs.md` when applicable |
| API documentation (opt-in) | Document this project's own implemented HTTP endpoints, from the code only | `<state-dir>/api/api-specs.md` |
| Bruno collection (opt-in) | Generate a runnable Bruno (OpenCollection YAML) collection from the API doc | `<state-dir>/api/bruno/` |

## Sizing the work

Pick the route and state it with one line of rationale before starting:
- **Trivial fix or a direct question:** handle it directly — a typo, a one-line fix, a rename. Anything beyond that goes through the pipeline.
- **Small change, clear requirements:** execution planning → implementation.
- **Feature with open questions, or any design-heavy change:** requirements & design → execution planning → implementation. If requirements are already fully clear, skip straight to the technical design half and note that the functional half is a given.
- **Unit testing, technical testing, code review, API documentation, and the Bruno collection are opt-in, never default.** Ask the user about all of them together, once, at sizing time — not one question per stage, not again later. By default, implementation still runs build/lint/tests and reports results; that is not the same as running a full technical-testing or code-review pass.
- **API contracts are a required input for integration work.** When a workstream calls or implements an HTTP API, point every stage at the relevant document: `<state-dir>/api/api-specs.md` for this project's own API, `<state-dir>/api/<service>/api-specs.md` for an upstream one. If the spec isn't vendored yet, get it in place first (see vendoring rule) — never infer a third party's contract from the calling code.
- **Frontend-consumes-backend is the same case.** Point the frontend work at `<state-dir>/api/api-specs.md` instead of reading backend source for the contract. If it's missing or stale for the endpoints in scope, run the API documentation stage first.
- **Vendoring an upstream spec is never the API-documentation stage's job — that stage documents this project's own code only.** Every upstream service gets its own subdirectory under `<state-dir>/api/`, never a flat file. Route by source type:
  - **Machine-readable spec** (OpenAPI/Swagger, Postman export, another repo's own `api-specs.md`): copy it verbatim into `<state-dir>/api/<service>/`, with a provenance header (source path/URL, date copied). A plain copy — no rewriting a contract that's already exact.
  - **Prose-only source** (PDF, Word doc, wiki/integration guide): run the document-distillation stage once, telling it this document is an upstream API contract and giving it the `<service>` slug; it writes both the docs summary and the house `api-specs.md` shape in the same pass.
  - Point every consuming stage at whichever file actually holds the contract.
- **This whole API/Bruno sub-pipeline is HTTP-only.** gRPC's `.proto` file is already the canonical contract — point any gRPC-touching stage straight at the `.proto` file(s), no distillation, no house spec file.
- **Source documents go through a summary check first.** Before reading an API spec, PDF, Word doc, or Postman collection, check `<state-dir>/docs/` for an existing summary; if one exists, use it instead of re-reading the original.

## Workflow

1. Read the project's root instructions file (`AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, or equivalent for this harness), plus any existing `<state-dir>/design-plan.md`, `<state-dir>/testing-plan.md`, `<state-dir>/temp/` documents, and `<state-dir>/docs/` summaries — never redo a stage whose deliverable is current.
2. Size the work, confirm the route with the user if it deviates from what they asked, and ask about every opt-in stage in one go.
3. Run the stages in order. After implementation, unit testing, technical testing, code review, and API documentation depend only on the implementation's output, not on each other — do them in any order, but the Bruno-collection stage always runs after API documentation, never before or alongside it (it reads `api-specs.md`).
4. Between stages: check the deliverable against its upstream inputs, resolve conflicts, and surface material risks immediately. The first time any stage writes into `<state-dir>/`, check `.gitignore` (below) and the root-index pointer (below) before moving on.
5. **API-spec staleness check.** After implementation, list every file it touched. If any corresponds to a documented HTTP handler, route, or request/response struct in `<state-dir>/api/api-specs.md`, that document is now stale — ask the user immediately whether to refresh it (and the Bruno collection, if one exists) rather than waiting for the next sizing pass.
6. After each stage, check the result against the user's *original* request, not just the previous document. Redo the stage if it falls short.
7. **A code-review fix round isn't closed when the fix lands.** Re-run code review against the fix's explicit file list to confirm each selected finding actually resolved and nothing regressed. Cap this at 3 fix/re-review cycles; if a finding is still open after that, escalate to the user as a ruling rather than looping again.
8. Close out by personally confirming build/lint/tests pass, every opted-in stage actually ran and its findings were addressed, and the original requirement is traceably satisfied. Re-run or re-read the actual command output before reporting a stage "passed" — don't just assert it.

## Rules

- **Don't ghost-write past what the stage produces.** Each stage's deliverable is the record of that stage's decisions — don't silently redecide a prior stage's output while doing a later one; go back and correct that stage's document instead.
- **Unit tests are written only during the unit-testing stage**, never as a side effect of implementation or planning — planning may only name *what* needs unit-level coverage.
- **Code review produces findings, never a plan.** Route selected findings into execution planning, then implementation. Don't act on the full report by default — the user (or you, on their behalf) chooses which findings get fixed.
- **Escalate only what's genuinely the user's call:** scope, budget/risk acceptance, business rules, and the opt-in stages. Technical and process calls are yours to make — give a definitive recommendation with the trade-off behind it.
- **Isolate implementation in a separate branch or worktree when your runtime supports one**, rather than committing directly on top of whatever's currently checked out, especially for anything beyond a trivial change.
- **Compact context between stages.** Carry forward the verdict, a pointer to the artifact, and any open risk — not the full working transcript of the stage that produced it.

## Git conventions

- **Gitignore upkeep.** The first time anything writes into `<state-dir>/`, ensure the repo-root `.gitignore` contains an entry ignoring that harness directory's `temp/` subfolder (e.g. `**/.codex/temp/`, `**/.cursor/temp/`, `**/.agents/temp/`).
  Everything else under `<state-dir>/` — `design-plan.md`, `testing-plan.md`, `api/`, `docs/` — is a shared deliverable and stays tracked.
- **Root-index pointer.** The document-distillation, API-documentation, and Bruno-collection stages don't touch the root instructions file. After any of them runs on its own (not immediately followed by an implementation stage), add or refresh a one-line pointer in the project's root instructions file to what they produced, so it's discoverable from the file every stage auto-loads.

## Bug review

List every issue found, each with fix options and concrete steps; wait for the user's choice before applying any fix.
