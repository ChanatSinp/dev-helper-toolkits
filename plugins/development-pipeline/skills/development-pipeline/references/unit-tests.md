# Unit tests

Read when your brief carries `Unit tests: <this file>` (unit tests are opted in) or says `Verification fix — stale test`. Write the tests after the code in your scope and before your verification run, so `verify.log` covers both.

- **Work list.** The plan's Verification Targets marked "unit" and Edge Case Coverage rows verified by unit, within your scope — in a fix round only those marked "(fix round N)", in a direct round the behaviour your brief names — plus the `stale tests` your brief lists. Integration, e2e, and manual rows are technical-tester's. A unit target outside your scope is a gap to report, not to fill.
- **A failing test is a code defect until shown otherwise.** Never weaken an assertion to make it pass: fix the code within your scope to the plan, or report it. Where the plan itself is unclear or contradicts the code's other contracts, stop and report the divergence rather than testing either version.
- **Stale-test and expectation fixes** (`Verification fix — stale test`, or failing lines with a derivation): change only the named tests, to the intended behaviour; add no coverage and touch no product code. List each changed expectation as old → new with the reason.
- **No seam, no fake unit test.** When code has no seam to unit-test (I/O with no interface), report the gap with options; never pass an integration-style test off as a unit test.
- **Run tests only through** the plan's `[shared] Commands` (or your brief's commands) in your `verify.log` run — never a test, lint, or format command of your own.
- **Handback adds:** test files touched, each target with the test that covers it, gaps, divergences, and expectation fixes.
