# Spec: Test suite revision

Status: ready-for-agent
Vocabulary: see `GLOSSARY.md` (Case, Expectation, Judged output, State, Fingerprint, Serialised form, Compute step, Shell, Review status, Agent approved, Human approved, Rejected, Rejection note, Platform variant).

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
| Static ggplot / base graphics | 1 | built/prepared data | fixed-font SVG |
| Condition (error/warning/message) | 1 (all conditions, in order) | class, key fields, plot still built | message text |
| Slider widget | declared slider positions | state data | each state + live use |
| plotly 3D | declared camera presets | trace data | each state + live use |
| Animation | first, last, N evenly spaced frames | frame data | each frame + playback |

**Fingerprints.** One fingerprint per state: a SHA-256 hash (via `digest`), shortened to 12 hex characters, of the state's serialised form encoded as UTF-8. The serialised form is stored next to the review state, so an agent can diff it against the last approved version (story 37). PNGs and screenshots are never fingerprinted; they exist only for viewing.

Every state comes from a compute step in R. For a static plot, that step is just building the plot. No browser, screenshot or GIF encoder is involved. Compute steps run under pinned options: `options(useFancyQuotes = FALSE, cli.unicode = FALSE, digits = 7, OutDec = ".", width = 80)`, plus the case's own `set.seed()`. The text they produce then goes through the **common normalisation** before it counts as the serialised form:

1. Line endings become `\n`, and trailing whitespace is removed from each line.
2. Absolute paths (`tempdir()`, the package root, the user's home folder) become `<tmp>`, `<pkg>` and `<home>`.
3. A numeric token whose value is zero (`-0`, `-0.00`, but not `-0.5`) loses its minus sign. A value that rounds to zero must not change sign between platforms.

Each output type then adds its own rules.

**Static ggplot.** *State:* one, the plot as printed. *Serialised form:* fixed-font SVG from vdiffr's engine, `vdiffr::write_svg(function() print(p), file)`. The plot is wrapped in a function on purpose. Passed directly, a ggplot without a theme gets `theme_test()`, but the suite judges the theme users actually see. *Normalisation:* none beyond the common rules. The engine already rounds coordinates and builds clip IDs from those rounded coordinates, so they are deterministic. It writes no timestamps or random IDs.

**Base graphics** (`slice_2d`, `add_slice_2d`). *State:* one, the device contents after the case's drawing code runs. *Serialised form:* the same engine, with the drawing code as a function: `vdiffr::write_svg(function() { slice_2d(m); add_slice_2d(m2) }, file)`. *Normalisation:* as for static ggplot.

**Condition text.** *State:* one per case, holding every condition the call raises, in order. Conditions raised by dependencies (for example ggplot2 dropping rows) are included, because a user sees them too. *Serialised form:* one block per condition: a header line `<kind>` (`error`, `warning` or `message`), then `conditionMessage()` verbatim. Blocks are separated by a blank line. *Normalisation:* ANSI escape codes are removed, and curly quotes (`‘’“”`) become straight ones, as a safety net behind `useFancyQuotes`. Numbers in wording are not rounded, because a changed number in a message is a wording change. The condition's class and key fields are expectations, not part of this form.

**Canonical JSON**, used by the remaining types: S3 classes are dropped recursively (plotly tags fields such as `zcolor`, which `jsonlite` refuses), numbers are rounded with `signif(x, 6)`, object keys are sorted recursively, and array order is kept. It is written with `jsonlite::toJSON(digits = I(6), auto_unbox = TRUE, null = "null", na = "null")`. plotly's own `to_JSON()` is not used: it writes 17 significant digits, and the extra digits are floating-point noise.

**Slider widget.** *States:* the slider positions declared by the case. One position assigns a value to every slider, for example `list(hp = 100, cyl = 6)`. The case declares positions as data: at minimum the start position plus each slider's minimum and maximum, with the other sliders held at their start values. *Compute step:* the slider's recipe (`function(predict_vars) -> ggplot`, as the slider prototypes require) is called at that position. *Serialised form:* two parts joined by a `---` line:
- the static ggplot form of the recipe's plot at that position, so labels, subtitle and line all count;
- the **shell**: the widget's non-state configuration as canonical JSON (slider names, ranges, steps, labels, starting position), its htmlwidget dependencies by name and version, and the SHA-256 of each JS and CSS file Applr ships for it, keyed by file path.

Because the shell is part of every state, a shell change resets the review status of every state of the widget.

**plotly 3D** (`scatter_3d`). *States:* the camera presets declared by the case (for example `default`, `top`, `side`). One preset is a `layout.scene.camera` value. *Compute step:* `plotly::plotly_build()` on the widget, then the preset's camera written into `layout.scene.camera`. *Serialised form:* canonical JSON of only `x$data`, `x$layout` and `x$config` from the built object, followed by a shell of the widget's htmlwidget dependencies (including plotly.js) by name and version. *Normalisation:* every other top-level field is dropped. `visdat`, `cur_data` and `attrs` are keyed by IDs that change on every build, and `source`, `base_url`, `highlight` and `shinyEvents` don't affect appearance. Any `uid` or `elementId` is dropped too. On `scatter_3d(lm(mpg ~ wt + hp, mtcars))` this form is identical across two builds and is 83 KB, compared with 196 KB from `to_JSON()`.

**Animation** (future). *States:* the first frame, the last frame, and N evenly spaced frames between them. N is declared by the case and defaults to 3. *Compute step:* the animation's frame step returns every frame as a ggplot (or as data a ggplot recipe draws), together with timing metadata, before any encoder runs. This is the same design rule as for sliders. *Serialised form:* the sampled frame's static ggplot form, plus a shell of the timing metadata (frame count, frames per second, duration, easing) as canonical JSON. Playback is judged live on the review page and is never fingerprinted.

**Prior art.** vdiffr ([r-lib/vdiffr](https://github.com/r-lib/vdiffr)) solves this problem for ggplot and base graphics. The suite reuses vdiffr's engine as a dev-only dependency (not in `DESCRIPTION`; install it before running judged outputs) rather than building its own. The relevant history, from its NEWS and `src/devSVG.cpp`:
- In 0.3.0 vdiffr embedded its own svglite "to protect against updates of the SVG generation engine". Plain svglite measures text with the system's fonts, so its output varies by operating system.
- From 0.4.0, text extents come from precomputed glyph sizes instead of FreeType, and 1.0.0 slimmed the engine down. Text is written as `font-family: sans` with a fixed `textLength` taken from Liberation metrics, so text widths don't depend on installed fonts.
- Clip IDs are base64 strings of the clip rectangle, rounded to two decimals. Text positions are written with `%0.2f`.
- Each SVG records `data-engine-version`. The suite stores that version with each fingerprint. When a reset to Unreviewed coincides with a change of engine version, the cause can then be told apart from a code change.
- 0.1.0 removed CR line endings before comparing, for Windows.

Deliberately not taken from vdiffr: testthat snapshot storage and `snapshot_review()`. They have no review status, and snapshot failures are not reported on CRAN.

**Open risks for cross-platform matching.** These are hypotheses for the cross-platform experiment to confirm or refute, per output type.
- **H1, engine:** with identical R, ggplot2, plotly and vdiffr versions, a static ggplot or base graphics SVG is byte-identical on Windows, macOS and Linux.
- **H2, floating point:** different BLAS, LAPACK or libm builds give last-bit differences in `lm()` and `predict()`. Rounding to two decimals (SVG) or 6 significant figures (JSON) hides these, except when a value sits on a rounding boundary. Expect rare single-coordinate mismatches, and record how often they happen.
- **H3, negative zero:** `-0.00` against `0.00` is the main source of H2 boundary cases. It caused the old suite's "near-zero rounding" Linux fix, and the common normalisation covers it.
- **H4, text:** `geom_slice_subtitle()` measures its wrap width from a `ggplotGrob`. Under vdiffr's fixed metrics the wrap should be identical. Under any other device it is not.
- **H5, condition wording:** quote style and cli's bullet symbols (`ℹ`, `✖`) depend on locale and UTF-8 support, which caused the old suite's curly-quote Linux fix. Pinned options plus the curly-to-straight rule should make wording identical.
- **H6, JSON:** canonical JSON (plotly forms, slider and animation shells) matches across platforms. The only risk is H2 at 6 significant figures.
- **H7, versions not platforms:** most real mismatches will come from different package versions rather than operating systems. The experiment pins versions and records `sessionInfo()`, so each mismatch can be blamed on one or the other.

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
