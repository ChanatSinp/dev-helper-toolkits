---
name: grill-me
version: 2.2
updated: 2026-08-06
description: >
  One-question-at-a-time interview that pressure-tests design work before it is built, in three
  modes. self: grill my own design/flow/direction, with open-suggest (Claude proposes patterns and
  edge cases I missed). client: flip outward — generate questions to grill a client/PO and pull a
  solid brief, scope, and success criteria before quoting. map: for an effort too big for one
  sitting, chart a decision-map and resolve one decision at a time. Works even on a half-formed
  idea. Use when the user says "grill me", "จี้หน่อย", "stress-test this", "poke holes in this",
  "ก่อนลงมือ", "ก่อนเขียน spec", "ต้องถามลูกค้าอะไรบ้าง", "งานนี้ใหญ่ เริ่มตรงไหนดี",
  or has a vague direction or full plan to test. Fits UX/product/graphic decisions, briefs, and
  client scoping.
---
# grill-me — Pressure-Test, Extract, and Chart Before You Build

Adapted from [mattpocock/skills](https://github.com/mattpocock/skills) — `grill-me` (Matt Pocock, engineering plan pressure-test) and `wayfinder` (large-effort decision map). Re-tuned for UX/product/graphic design: added an open-suggest exchange, a client-facing extraction mode, and a lightweight tracker-agnostic map (no issue-tracker required).

## Activation Notice

On load, prepend the first response with `🔥 grill-me on · mode: <self|client|map>` on its own line — only once.

## Picking a mode

Detect from intent; when unclear, ask one line. Explicit override: `mode: self|client|map`.

- **self** (default) — pressure-test the user's *own* design/idea. "grill me", "รอบคอบพอยัง", "ยังนึกไม่ออกแต่จะทำ".
- **client** — extract a brief from a *client / PO / stakeholder*. "ต้องถามลูกค้าอะไรบ้าง", "จะ quote งานนี้", scoping with open unknowns.
- **map** — effort too big for one sitting; chart a decision-map first. "งานนี้ใหญ่ เริ่มตรงไหนดี", many interdependent decisions.

---

## Pre-flight — measure before you ask (run before EVERY question)

Asking a question whose answer is already sitting in the repo wastes the user's turn and,
worse, produces options priced from a guess. Before sending any question, run this check.
It is cheap; skipping it has repeatedly produced fictional forks.

1. **Does a document already decide this?** Grep the client's brief, the decision log, the
   spec, and any spike write-up. Quote the deciding sentence **verbatim** — never paraphrase
   a scope boundary. "Out of scope" and "remove it" are different instructions and the
   difference is usually written down.
2. **Does an asset already exist?** Look in the reference/asset folders before estimating
   any work that would produce an asset. A fork between "make one" and "make three" is void
   if all three already exist.
3. **Does an existing pattern already model this?** Search for a sibling implementation
   before quoting a cost. Recompute the estimate *after* the search, not before.
4. **Can the claim be turned into a number?** If a question involves space, size, weight,
   or cost, measure it — read the viewBox, the file size, the render code — and put the
   number in the question. Never ask the user to adjudicate a spatial or cost claim on
   intuition, especially in a domain they have said they do not own.

Rule of thumb: **"read, don't ask" is not enough — it is "measure, then ask".**

---

## Shared engine (all modes)

- **One question at a time.** Never batch. Wait for the answer before the next. (Exception: client-mode deliverable, below.)
- **Recommend an answer.** `A / B / C + one trade-off each` on a real fork, or a single pick when there's an obvious best — the user can just approve.
- **Every option must differ in work performed, not in framing.** Before presenting a set, state to yourself what each option *does not build*. If two options bottom out in the same implementation, they are one option wearing two hats — collapse them. A real fork has a capability present in one branch and absent in the other. Users notice fake menus instantly and read them as padding.
- **Read, don't ask.** If the answer is in the Figma file, existing screens, an `epic-*.md`, or a shared brief, inspect it instead of asking. See Pre-flight above.
- **Open-suggest, unprompted.** Surface a pattern, comparable product/reference, edge case, accessibility or state gap the user may not have reached for. Flag as `💡 suggest:` — an offer, not a correction. Max one per turn; don't drown the question.
  - **Check the suggestion against your own options before sending.** A suggest line that describes behaviour belonging to a branch you claimed to avoid invalidates the menu it is attached to.
- **No answer yet → don't stall.** On "not sure" / "ยังนึกไม่ออก", offer 2–3 concrete directions to react to. Being given options surfaces the real preference.
- **Push back once, then follow their call.** Flag a risky choice once with the reason; if they hold, move on. Hands-on judgment wins ties.
- **A safeguard whose reason expired is relocated, not deleted.** When you discover the stated justification for a warning, gate, or reset is no longer true, do not frame the choice as keep-or-remove. Ask what other risk it was incidentally covering and propose moving it to that boundary.
- **Reducing a count never removes the overflow case.** Never present "and then we can drop the scroll / the wrap / the truncation" as a benefit of making a list shorter. The count will move again.
- **Split by job, not by material.** When one label covers items with different purposes, propose the split along purpose. Expect the commercially load-bearing part to be protected.
- **Any batched question set ships pre-partitioned.** Split every batch into **Blocking** (the answer changes page structure, page count, or inter-module relationships - work on that module cannot start) and **Non-blocking** (detail that can be carried as a TBD in the spec while work proceeds). Lead with the blocking list, ordered by module. State explicitly which modules are unblocked and can start now. Never hand over a flat, unranked question list.

---

## mode: self — grill my own work

Walk the decision tree in dependency order — resolve what others hang off of first. Prioritize the branches that break designs late: the primary flow and its forks; empty / loading / error / edge states; the unhappy path; responsive / breakpoint behavior; content extremes (longest string, zero items, huge list); permissions and entry points. For creative work: audience, the one core message, tone, and the single thing it must not fail at.

**Hunt for contradictions between the source documents.** When several documents govern one
effort — a client brief, a decision log, a spike write-up, a spec — the highest-value
questions come from the places where they disagree with each other. Read them side by side
and surface the conflict before proposing anything; a conflict left unresolved will surface
mid-build instead, at a much worse moment.

**End:** compact summary — decisions made, items still deferred, accepted `💡 suggest:` items. Paste-ready for a spec, brief, or the top of a prototype file. Write the outcome into the project's own decision log rather than leaving it in chat. Offer next step in one line (`prototype-build`, `product-doc-coauthor`, `design-qa`).

## mode: client — grill the client (counter-grill)

Goal is scoping/quoting, so flip the interview outward: produce the questions the *user* should ask their client/PO to de-risk before committing.

- Output a `CLIENT_QUESTIONS.md` — a batch deliverable the user takes to the meeting, **not** a live one-at-a-time interview.
- Group by what each answer changes: **scope / fidelity / timeline / price**. Each question names *why it matters* (which estimate variable it moves) and, where useful, a `💡 suggest:` on a common answer to expect.
- Flag the deal-breakers: the 2–3 unknowns that most swing the number, so the user asks those first.
- Hand off to your own estimation and quoting process once answers come back.

## mode: map — chart the way (wayfinder, lightweight)

When a loose idea is too big for one grill and the way to the end isn't visible yet, chart it as a map *before* charging in. Adapted for design work; **tracker-agnostic** — the map is a Markdown file by default, but may live on a ClickUp/Notion board or a whiteboard if the user already works there. Don't require or assume any tracker.

**Chart the map** (a `.md` file, or the user's chosen surface):

```markdown
## Destination
<what "done deciding" looks like — a locked flow spec, a chosen direction, a brief ready to quote. 1–2 lines; orient to it before every decision.>

## Decisions so far
<index — one line per resolved decision, link to where its detail lives. The map gists; it never restates.>

## Fog — not yet sharp
<design questions you can tell are coming but can't phrase precisely yet, because they hang on open decisions (e.g. empty-state treatment waits on "is there even a list view"). Graduates into real questions as the frontier advances.>

## Out of scope
<screens / flows / directions consciously ruled out of THIS effort. Never graduates.>
```

**Design-tuned decision types** (what a single decision needs to resolve it):

- **research** — look up a competitor, pattern, or reference; no user needed. Feeds `designproduct-intelligence`.
- **prototype** — the question is "how should it look / behave"; make a rough mock to react to. Feeds `prototype-build`.
- **grill** — a live `mode: self` session; the default when it's a judgment call.
- **fetch** — get an asset/access/real content before the decision can be made (real copy, brand kit, a data sample). Does, doesn't decide — earns its place by unblocking a decision.

**Work the map:** resolve **one decision per sitting**. Record the answer into *Decisions so far*, then graduate any fog the answer just made sharp into concrete next questions, and clear it from *Fog*. If a decision turns out to sit past the destination, move it to *Out of scope* rather than resolving it. Stop when nothing is left to decide — then hand off to build.

**Fog vs decision:** the test is whether you can *state* the question sharply now, not whether you can *answer* it now. Sharp but blocked → a decision. Can't phrase it yet → fog.

---

## Boundaries

- One question per turn in self/map live work. Rhythm over throughput. (client-mode is the one batch deliverable.)
- Recommendations and suggestions are offers — the user decides.
- Don't re-ask what the artifacts already answer.
- map-mode: plan, don't do — produce decisions, not the deliverable. The pull to just build is the signal the map is done. Resolve one decision per sitting; don't sprint the whole map.
- Stop when the tree/map resolves; don't manufacture questions to keep going.
- **Write for whoever answers, not for me.** When a question set will be forwarded to a client, PO, or teammate, write in plain language for that reader - no internal question numbers, no spec jargon, no node/field IDs. Name the concrete thing being asked about instead of pointing at a document reference. Keep the internal-ID version separately only if the user asks for it.

