# Spec: Test suite revision

Status: ready-for-agent
Vocabulary: see `CONTEXT.md` (Case, Expectation, Judged output, State, Fingerprint, Review status, Agent approved, Human approved, Rejected, Rejection note, Platform variant).

## Problem Statement

The current suite runs 181 cases and reports "OK" when a case runs and its console output matches a snapshot. Nothing requires anyone to look at the plots, so a visual regression can pass forever unnoticed. There is no difference between what a script verified, what an agent looked at, and what a human approved. Cases are split into "console" and "visual" types, even though most behaviour is both (a warning case that produces no plot should fail). Reviewing means scrolling one long report to find the one case that matters, and the same plots must be re-checked every run whether or not they changed. Correctness of plotted lines is judged by eye against reference images, when it could be computed. The suite can't handle the outputs Applr is about to produce: JavaScript sliders, interactive plotly 3D charts and animations. It is also excluded from the built package, so CRAN effectively tests almost nothing.

## Solution

Every case is made of two kinds of thing.

- **Expectations** are deterministic pass/fail statements: numbers computed from the model, which conditions are raised, the structure of an output. Expectations never need review. They are what CRAN runs, within its time and two-thread limits.
- **Judged outputs** are anything needing judgment: plot appearance, message wording, the states of interactive outputs and animations. Each state of a judged output gets a fingerprint and carries a review status: Unreviewed → Agent approved → Human approved, or Rejected with a rejection note.

A fingerprint never decides correctness. It only decides whether an output keeps its review status: same fingerprint, status kept; new fingerprint, back to Unreviewed. A change appears in a reviewer's queue only when it actually changed something.

Agents take the first pass on every Unreviewed output (static plots, wording, and sampled states of interactive outputs and animations). Every agent approval carries a note and moves the output to the human queue. Only a person can grant Human approved, through a local review page: an inbox of queued cases, swipe or side-by-side comparison against the last approved render, live interactive widgets, a whole-suite overview, deep links to any one case, and rejection with a note for the agent.

How CI (GitHub Actions) treats each review status, and whether fingerprints can match across operating systems, are decided by a cross-platform experiment that comes first. The new cases are written from scratch, not migrated. First, a salvage step mines the old suite for what's valuable: what each function needs to do, which edge cases come up, and any test code worth keeping. The result is a temporary, principle-based behaviour inventory. New cases are then written from that inventory, organised by test type rather than by function.

## User Stories

1. As the maintainer, I want every judged output to require my approval before it counts as done, so that no visual regression can pass unnoticed.
2. As the maintainer, I want an output I already approved to stay approved while its fingerprint doesn't change, so that I never re-review unchanged plots.
3. As the maintainer, I want any change to a judged output's fingerprint to reset its review status to Unreviewed, so that every real change gets looked at.
4. As the maintainer, I want to see whether a status came from a script, an agent or me, so that I know how much to trust it.
5. As the maintainer, I want plotted lines checked numerically against the model's predictions, so that correctness doesn't depend on my eyesight.
6. As the maintainer, I want one case to be able to assert both "this warning is raised" and "a plot is still built", so that warning cases don't need a separate console type.
7. As the maintainer, I want each expectation and judged output reported separately inside a case, so that I can still isolate which part failed.
8. As the maintainer, I want a review page that opens on my queue, so that I start on what needs me.
9. As the maintainer, I want to search for any case by ID and jump straight to it, so that I don't dig through a long report.
10. As the maintainer, I want a deep link to any single case, so that an agent or the runner can hand me exactly the case to look at.
11. As the maintainer, I want to compare a new render against the last approved one by swiping or side by side, so that small differences are obvious.
12. As the maintainer, I want to read the agent's note before deciding, so that I can check its claim rather than start from scratch.
13. As the maintainer, I want to see the expected behaviour for a case next to its output, so that I judge against the spec, not my memory.
14. As the maintainer, I want console wording changes shown as a diff, so that I can judge message quality quickly.
15. As the maintainer, I want to open and use an interactive widget on the review page before approving it, so that I judge how it actually feels to use.
16. As the maintainer, I want sampled states of an interactive output shown side by side, so that I see its range at a glance.
17. As the maintainer, I want to reject with a note written for the agent, with quick starter phrases, so that a rejection is actionable.
18. As the maintainer, I want approve/reject and queue navigation on keyboard shortcuts, so that working through the queue is fast.
19. As the maintainer, I want to see queue progress, so that I know when I'm done.
20. As the maintainer, I want a whole-suite overview grouped by function and coloured by review status, so that I can see the health of the suite at once.
21. As the maintainer, I want a collapsible sidebar, so that the plot gets the whole screen when I need it.
22. As the maintainer, I want only my approvals to grant Human approved, and agents blocked from writing it, so that the extra authority is real.
23. As the maintainer, I want my local fingerprints to be the main loop, so that I can iterate quickly on my own machine.
24. As the maintainer, I want to know whether fingerprints can match across Windows, macOS and Linux before committing to a design, so that I don't build on a guess.
25. As the maintainer, I want an agent to approve a platform variant of something I already approved, with a note on what differs, so that operating-system differences don't flood my queue.
26. As the maintainer, I want CRAN to run only fast, deterministic expectations, so that the package respects CRAN's time and two-thread limits.
27. As the maintainer, I want expectations to ship in the built package, so that CRAN actually tests correctness.
28. As the maintainer, I want slow outputs (browser screenshots, animations) rendered only when something is Unreviewed, so that they never slow the quick checks.
29. As the maintainer, I want a release check that blocks a CRAN submission until everything is Human approved, so that nothing I haven't seen ships.
30. As the maintainer, I want the new cases written from scratch, from a principle-based inventory of what each function must do, so that the old suite's wording and structure don't carry over.
31. As the maintainer, I want the edge cases the old suite discovered preserved as principles with workable options, so that hard-won coverage isn't lost in the rewrite.
32. As the maintainer, I want useful old test code (data generators, models, oracle builders, helpers) salvaged, so that the rewrite doesn't redo solved work.
33. As the maintainer, I want new cases organised by test type (numeric, condition, static appearance, interactive), so that one behaviour shared by several functions is tested once, consistently.
34. As the maintainer, I want a clear guide for adding a new feature or output type to the suite, so that future agents extend it consistently.
35. As a coding agent, I want to run only the expectations for the code I touched, so that my loop is fast.
36. As a coding agent, I want a list of exactly which judged outputs are Unreviewed, so that I review only what changed.
37. As a coding agent, I want to see a text diff of an output against its last approved version, so that I can say precisely what changed.
38. As a coding agent, I want to record an approval or rejection with a required note, so that the human understands my reasoning.
39. As a coding agent, I want to read the human's rejection note on a case, so that I know what to fix.
40. As a coding agent, I want sampled states of interactive outputs and animations rendered as images, so that I can take a first pass on outputs I can't operate.
41. As a coding agent, I want to declare the states of a new output type in one place, so that fingerprinting, screenshots and review all follow.
42. As a coding agent, I want expectations to read computed data at the highest available seam (built layer data, prepared slice data, built plotly traces, computed slider states), so that tests don't depend on drawing.
43. As a future contributor, I want terms like fingerprint and review status defined in a glossary, so that the vocabulary is unambiguous.
44. As the maintainer, I want the GitHub runs on the test-suite branch kept separate from `main`, so that the experiment doesn't disturb anything else.

## Implementation Decisions

**Two halves of a case.** A case is one readable file per scenario. It declares expectations (testthat `expect_*()` statements) and judged outputs (named outputs with their states). The old console/visual case types are removed.

**Engine.** Expectations run under testthat and ship with the package. Fingerprinting, review state and the review queue live in a separate dev-only module outside the built package, because testthat has no concept of review status. Snapshot-style expectations that testthat skips on CRAN are not relied on for correctness.

**Testing seams (highest available, no refactor needed for existing code).**
- `geom_slice` and the other `geom_slice_*` layers: ggplot2's built layer data and built plot labels.
- `slice_2d` / `add_slice_2d`: the existing internal prepare step, which returns line data before drawing.
- `scatter_3d`: the built plotly object's trace data.
- Sliders and animations (future): a compute step that returns all states as data, with a thin renderer on top. This is a design rule for new features, not a retrofit.

**Numeric oracle.** Expectations compare plotted data against the model's predictions on an expected grid that the test builds independently. The prediction function itself is trusted, not tested. This replaces eyeballing reference images for line shape, slope and position.

**Output types and states.** Each output type defines its states.

| Output type | States | Expectations on | Judged as |
|---|---|---|---|
| Static ggplot / base graphics | 1 | built/prepared data | rendered SVG |
| Condition (error/warning/message) | – | class, key fields, plot still built | message text |
| Slider widget | declared slider positions | state data | each state + live use |
| plotly 3D | declared camera presets | trace data | each state + live use |
| Animation | first, last, N evenly spaced frames | frame data | each frame + playback |

**Fingerprints.** One fingerprint per state, computed from a serialised text form with noise removed (rounded coordinates, random widget IDs and timestamps stripped). Exactly what is serialised and stripped per output type is defined by the first ticket. PNGs and screenshots are never fingerprinted; they exist only for viewing.

**Review status rules.** Encodes the decisions above. Trimmed from the logic prototype and corrected to the final model.

```
on run:
  expectations fail                 -> case fails; review untouched
  state fingerprint == recorded     -> keep review status
  state fingerprint != recorded     -> Unreviewed

Unreviewed       --agent approve (note required)--> Agent approved
Unreviewed       --agent reject  (note required)--> Rejected
Agent approved   --human approve-->                 Human approved
Agent approved   --human reject  (note)-->          Rejected
Rejected         --code changes fingerprint-->      Unreviewed
Platform variant of Human approved --agent approve (note)--> Human approved for that platform
```

The human never sees an Unreviewed output before an agent pass. This applies to interactive outputs too: agents review their sampled states.

**Review state storage.** A dev-only review state file records, per case and state: fingerprint, review status, who set it, when, the agent note, and any rejection note. The human part of this file is written only by the review server.

**Human authority.** A Claude Code hook blocks agent writes to the human part of the review state. The review server is the only writer of Human approved.

**Review page.** A small local server started from R (httpuv) serves the review page and records decisions. Layout from the review page prototype (v2):
- the inbox is the default view;
- a collapsible sidebar groups cases by review status, with search;
- the suite overview (tiles by function family) is a sidebar destination;
- each case shows its expected behaviour, the agent note, any console diff, and a swipe or side-by-side comparison, or sampled states plus the live widget for interactive outputs;
- reject opens a note box with quick starter phrases;
- keyboard: j/k, a, r, s, o, [, and Ctrl+Enter;
- the URL deep-links to a case or to the overview.

**Screenshots.** Interactive states are captured with headless Chrome via chromote (dev-only), driven by a hook in the widget that sets a given state, so captures are deterministic. They are captured only for Unreviewed states.

**CI.** A workflow runs on pushes to the test-suite branch only. It's used first by the cross-platform experiment. How CI maps review statuses to ✓/✗, and whether local fingerprints are authoritative across platforms, are **deferred to the experiment's result**. The working proposal: Rejected and Unreviewed fail, Agent approved warns, and a separate release check requires everything to be Human approved.

**Salvage, then write from scratch.** The new suite is a reinvention, not a migration. It happens in two phases.

1. **Salvage (one dedicated session).** Mine the old suite for what's valuable and record it in a temporary **behaviour inventory** next to this spec. Sources:
   - the old cases' `# EXPECT:` headers and test code;
   - the reference-image build scripts;
   - the maintainer's notes on testing revisions in the dev docs.

   The inventory is principle-based, not wording-specific. For each function it records:
   - **what the function must do**: its behaviours, stated as principles;
   - **the edge cases that come up**: each with the principle at stake and workable options for testing it, not the old case's exact assertion;
   - **shared behaviours** that cut across functions (input validation, back-transforms, imputation, facet/group slicing), so each is tested once;
   - **salvageable test code**: data generators, models, oracle builders and helpers worth carrying over, each with a note on why.

   Individual `# EXPECT:` statements are not carried over verbatim. The inventory is the only bridge from the old suite. Writing tickets never read old cases directly.

2. **Write by test type.** New cases are written from scratch from the inventory, split by test type, not by function:
   - **numeric** expectations;
   - **condition** expectations, with message wording as judged outputs;
   - **static appearance** judged outputs;
   - **interactive** states.

   Each writing ticket covers its type across every function the inventory lists.

The inventory is deleted when the last writing ticket lands. Infrastructure tickets don't depend on it.

**Documentation.** The tests README is rewritten as the guide for adding features and output types to the suite. The test-suite iteration loop in `CLAUDE.md` is replaced by a short pointer to that guide. It may become a skill later.

## Testing Decisions

- A good test asserts external behaviour at the highest seam: what data a plot will draw, what condition a user sees. Never private helpers or drawing internals.
- The suite's own infrastructure (fingerprint normalisation, review status transitions, the review server's write rules) gets ordinary unit tests, because it is deterministic.
- The review status rules are tested as a pure function of (recorded state, new fingerprint, action) → new state, mirroring the logic prototype's reducer shape.
- Prior art: the existing testthat files are already the expectation style at a smaller scale, and the current runner's blank-PNG detection is the precedent for "a plot was still built".
- Expectations must finish in about a minute in total and use two threads or fewer. Anything needing a browser or network is skipped on CRAN.

## Out of Scope

- Migrating old cases one-for-one, or preserving any old `# EXPECT:` wording.
- Vignette figures as judged outputs (later ticket).
- Turning the guide into a skill.
- Building the slider, plotly-preset and animation features themselves; only prototype outputs of them are used by the experiment.
- Changes to the CRAN R CMD check workflow on `main`.

## Further Notes

- Prototypes: `scratch/test_suite_prototype/logic_ladder.html` (superseded tier model, kept for history) and `review_page_v2.html` (the accepted layout). `scratch/` is gitignored, so commit them to a throwaway branch if they're to be kept as a source.
- Decided locations: this spec and the temporary behaviour inventory live in `for_devs/`; tickets live in `for_devs/tickets/`, because issues are disabled on the repository.
- The old runner may keep working until the new suite replaces it; the work happens on a dedicated branch.
