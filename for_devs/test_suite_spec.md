# Spec: Test suite revision

Status: ready-for-agent
Vocabulary: see `GLOSSARY.md` (Case, Expectation, Judged output, State, Fingerprint, Serialised form, Compute step, Shell, Payload, Review status, Agent approved, Human approved, Rejected, Rejection note, Platform variant).

> When you change a principle or the structure here, update the review page's suite guide pages to match. They are the maintainer's plain-language version of this spec and `tests/suite/README.md`.

## Problem Statement

The current suite runs 181 cases and reports "OK" when a case runs and its console output matches a snapshot. Nothing requires anyone to look at the plots, so a visual regression can pass forever unnoticed. There is no difference between what a script verified, what an agent looked at, and what a human approved. Cases are split into "console" and "visual" types, even though most behaviour is both (a warning case that produces no plot should fail). Reviewing means scrolling one long report to find the one case that matters, and the same plots must be re-checked every run whether or not they changed. Correctness of plotted lines is judged by eye against reference images, when it could be computed. The suite can't handle the outputs Applr is about to produce: JavaScript sliders, interactive plotly 3D charts and animations. It is also excluded from the built package, so CRAN effectively tests almost nothing.

## Solution

Every case is made of two kinds of thing.

- **Expectations** are deterministic pass/fail statements: numbers computed from the model, which conditions are raised, the structure of an output. Expectations never need review. They are what CRAN runs, within its time and two-thread limits.
- **Judged outputs** are anything needing judgment: plot appearance, message wording, interactive outputs and animations. Each judged output gets one fingerprint and carries one review status: Unreviewed → Agent approved → Human approved, or Rejected with a rejection note. An interactive output or animation is judged as a whole; its states are views a reviewer samples, not separately approved pieces.

A fingerprint never decides correctness. It only decides whether an output keeps its review status: same fingerprint, status kept; new fingerprint, back to Unreviewed. A change appears in a reviewer's queue only when it actually changed something.

Agents take the first pass on every Unreviewed output (static plots, wording, and sampled states of interactive outputs and animations). Every agent approval carries a note and moves the output to the human queue. Only a person can grant Human approved, through a local review page: an inbox of queued cases, swipe or side-by-side comparison against the last approved render, live interactive widgets, a whole-suite overview, deep links to any one case, and rejection with a note for the agent.

How CI (GitHub Actions) treats each review status, and whether fingerprints can match across operating systems, are decided by a cross-platform experiment that comes first. The new cases are written from scratch, not migrated: write first, then salvage. A temporary, principle-based behaviour inventory of what each function must do and which edge cases come up is written from the docs and the source, without reading the old suite. New cases are written from that inventory, organised by test type rather than by function. The old suite is deleted from the branch before writing starts and kept only in a tag. Once the new cases are written, a salvage audit reads it from that tag, looking for the kinds of situation it tested that the new suite misses.

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
30. As the maintainer, I want the new cases written from scratch, from a principle-based inventory of what each function must do, written from the docs and source rather than the old suite, so that the old suite's wording and structure don't carry over.
31. As the maintainer, I want the old suite audited only after the new one is written, for the kinds of situation it tested that the new suite misses, so that hard-won coverage isn't lost and the new suite isn't shaped by the old one.
32. As the maintainer, I want the old suite deleted from the branch before new cases are written, kept only in a tag for the audit, so that it can't shape the new suite.
33. As the maintainer, I want new cases organised by test type (numeric, condition, static appearance, interactive), so that one behaviour shared by several functions is tested once, consistently.
34. As the maintainer, I want a clear guide for adding a new feature or output type to the suite, so that future agents extend it consistently.
35. As a coding agent, I want to run only the expectations for the code I touched, so that my loop is fast.
36. As a coding agent, I want a list of exactly which judged outputs are Unreviewed, so that I review only what changed.
37. As a coding agent, I want to see a text diff of an output against its last approved version, so that I can say precisely what changed.
38. As a coding agent, I want to record an approval or rejection with a required note, so that the human understands my reasoning.
39. As a coding agent, I want to read the human's rejection note on a case, so that I know what to fix.
40. As a coding agent, I want sampled states of interactive outputs and animations rendered as images, so that I can take a first pass on outputs I can't operate.
41. As a coding agent, I want to declare a new output type's fingerprint inputs and review states in one place, so that fingerprinting, screenshots and review all follow.
42. As a coding agent, I want expectations to read computed data at the highest available seam (built layer data, prepared slice data, built plotly traces, computed slider payloads), so that tests don't depend on drawing.
43. As a future contributor, I want terms like fingerprint and review status defined in a glossary, so that the vocabulary is unambiguous.
44. As the maintainer, I want the GitHub runs on the test-suite branch kept separate from `main`, so that the experiment doesn't disturb anything else.

## Implementation Decisions

**Two halves of a case.** A case is one readable file per scenario. It declares expectations (testthat `expect_*()` statements) and judged outputs (named outputs with their states). The old console/visual case types are removed.

**Engine.** Expectations run under testthat and ship with the package. Fingerprinting, review state and the review queue live in a separate dev-only module outside the built package, because testthat has no concept of review status. Snapshot-style expectations that testthat skips on CRAN are not relied on for correctness.

**Testing seams (highest available, no refactor needed for existing code).**
- `geom_slice` and the other `geom_slice_*` layers: ggplot2's built layer data and built plot labels.
- `slice_2d` / `add_slice_2d`: the existing internal prepare step, which returns line data before drawing.
- `scatter_3d`: the built plotly object's trace data.
- Sliders and animations (future): a compute step that returns, as data, everything their states are drawn from, with a thin renderer on top. This is a design rule for new features, not a retrofit.

**Numeric oracle.** Expectations compare plotted data against the model's predictions on an expected grid that the test builds independently. The prediction function itself is trusted, not tested. This replaces eyeballing reference images for line shape, slope and position.

**Output types and states.** Each output type defines what its fingerprint is taken from, and which states a reviewer sees.

| Output type | Fingerprinted from | States (views for review) | Expectations on | Judged as |
|---|---|---|---|---|
| Static ggplot / base graphics | fixed-font SVG | 1 | built/prepared data | the plot |
| Condition (error/warning/message) | message text | 1 (all conditions, in order) | class, key fields, plot still built | the wording |
| Slider widget | payload, background SVG, shell | declared slider positions | payload evaluated against predictions | sampled states + live use |
| plotly 3D | figure JSON, presets, shell | declared camera presets | trace data | sampled states + live use |
| Animation | every frame's data, style SVG, shell | first, last, N evenly spaced frames | frame data | sampled frames + playback |

**One contract per output type.** Each row above is one registration, in its own file. It gives how to serialise an object into named parts, the output's states, how to render a state for viewing, and the view kind the review page draws (image, text diff, or states plus a live widget). The runner, the review state and the review page know only the contract and never name a type. A new kind of output, including ones not foreseen here, is added by registering a type. A unit test proves this: a deliberately odd fake type, defined only in that test, goes from run to the review page with no edits to the core.

**Fingerprints.** One fingerprint per judged output. Every output type, including future ones, follows one principle:

> Fingerprint the inputs of the deterministic renderer, at the last point before code Applr doesn't control. Hash everything Applr controls that reaches the viewer; record by version what it doesn't.

For a static plot that point is the SVG, since whatever displays it is outside Applr. For a widget it is the data the page is built from plus Applr's own JS: the browser turns those into every reachable state, so hashing them covers every state, not a sample, and costs one build however many states there are. States are therefore never fingerprinted one by one. They are views, rendered only for Unreviewed outputs so an agent can review what it can't operate (see Screenshots).

The fingerprint is a SHA-256 hash (via `digest`), shortened to 12 hex characters, of the output's serialised form encoded as UTF-8. The serialised form is a list of named **parts** (such as `payload`, `background` and `shell`), each normalised on its own and joined in a fixed order, each under a `--- <name>` header line. A single-part output (a static plot, condition text) has no header. The serialised form is stored next to the review state, so an agent can diff it against the last approved version and see which part changed (story 37). PNGs and screenshots are never fingerprinted; they exist only for viewing.

Every part comes from a compute step in R. For a static plot, that step is just building the plot. No browser, screenshot or GIF encoder is involved. Compute steps run under pinned options: `options(useFancyQuotes = FALSE, cli.unicode = FALSE, digits = 7, OutDec = ".", width = 80)`, plus the case's own `set.seed()`. The text they produce then goes through the **common normalisation** before it counts as the serialised form:

1. Line endings become `\n`, and trailing whitespace is removed from each line.
2. Absolute paths (`tempdir()`, the package root, the user's home folder) become `<tmp>`, `<pkg>` and `<home>`.
3. A numeric token whose value is zero (`-0`, `-0.00`, but not `-0.5`) loses its minus sign. A value that rounds to zero must not change sign between platforms.

Each output type then adds its own rules.

**Static ggplot.** *State:* one, the plot as printed. *Serialised form:* fixed-font SVG from vdiffr's engine, `vdiffr::write_svg(function() print(p), file)`. The plot is wrapped in a function on purpose. Passed directly, a ggplot without a theme gets `theme_test()`, but the suite judges the theme users actually see. *Normalisation:* none beyond the common rules. The engine already rounds coordinates and builds clip IDs from those rounded coordinates, so they are deterministic. It writes no timestamps or random IDs.

**Base graphics** (`slice_2d`, `add_slice_2d`). *State:* one, the device contents after the case's drawing code runs. *Serialised form:* the same engine, with the drawing code as a function: `vdiffr::write_svg(function() { slice_2d(m); add_slice_2d(m2) }, file)`. *Normalisation:* as for static ggplot.

**Condition text.** *State:* one per case, holding every condition the call raises, in order. Conditions raised by dependencies (for example ggplot2 dropping rows) are included, because a user sees them too. *Serialised form:* one block per condition: a header line `<kind>` (`error`, `warning` or `message`), then `conditionMessage()` verbatim. Blocks are separated by a blank line. *Normalisation:* ANSI escape codes are removed, and curly quotes (`‘’“”`) become straight ones, as a safety net behind `useFancyQuotes`. Numbers in wording are not rounded, because a changed number in a message is a wording change. The condition's class and key fields are expectations, not part of this form.

**Canonical JSON**, used by the remaining types: S3 classes are dropped recursively (plotly tags fields such as `zcolor`, which `jsonlite` refuses), numbers are rounded with `signif(x, 6)`, object keys are sorted recursively, and array order is kept. A string that is entirely a decimal number with a fractional part or an exponent (`"0.0833333333333334"`, `".5"`, `"1e-17"`) is rounded the same way and stays a string. plotly stores colorscale stops like this, and in the cross-platform experiment one differed in the last bit on Ubuntu. Integer-looking strings and strings with any other character are left alone, because they are more likely IDs or labels than measurements. The rule lives in canonical JSON rather than in the plotly type, so slider payloads, animation frames and future types get it too. It is written with `jsonlite::toJSON(digits = I(6), auto_unbox = TRUE, null = "null", na = "null")`. plotly's own `to_JSON()` is not used: it writes 17 significant digits, and the extra digits are floating-point noise.

**Slider widget.** The page computes every curve from a small payload that all slider positions borrow from, rather than from stored states. *Compute step:* building the payload and the background plot, once. *Serialised form:* three parts:
- `payload`: canonical JSON of the object embedded in the widget, not a copy of it: the per-line x-side designs, the slider tables (or their low-rank factors for coupled sliders), the coefficients, covariance and interval constants, the post-map spec, and the line and ribbon styling read from the built layer;
- `background`: the static ggplot form of the plot the curves are drawn over. It goes through vdiffr's engine, not the SVG the widget ships, because svglite writes that with system font metrics; svglite's version goes in the shell instead;
- `shell`: the widget's configuration as canonical JSON (slider names, ranges, steps, labels, starting position), its htmlwidget dependencies by name and version, and the SHA-256 of each JS and CSS file Applr ships for it, keyed by file path.

*States:* the slider positions declared by the case, as data. One position assigns a value to every slider, for example `list(hp = 100, cyl = 6)`. At minimum: the start position plus each slider's minimum and maximum, with the other sliders held at their start values. States only choose which screenshots a reviewer sees. *Expectations:* the payload's arithmetic, evaluated in R as the page does it, matches `predict()` at the declared positions and at random reachable ones. This is the slider's build-time self-test, run as a case.

**plotly 3D** (`scatter_3d`). *Compute step:* `plotly::plotly_build()` on the widget, once. *Serialised form:* three parts: `figure`, canonical JSON of only `x$data`, `x$layout` and `x$config` from the built object; `presets`, the case's camera presets as canonical JSON; and `shell`, the widget's htmlwidget dependencies (including plotly.js) by name and version. *States:* the camera presets (for example `default`, `top`, `side`). One preset is a `layout.scene.camera` value, written into the figure only when its screenshot is taken. *Normalisation:* every other top-level field is dropped. `visdat`, `cur_data` and `attrs` are keyed by IDs that change on every build, and `source`, `base_url`, `highlight` and `shinyEvents` don't affect appearance. Any `uid` or `elementId` is dropped too. On `scatter_3d(lm(mpg ~ wt + hp, mtcars))` this form is identical across two builds and is 83 KB, compared with 196 KB from `to_JSON()`.

**Animation** (future). *Compute step:* the animation's frame step returns every frame as data a ggplot recipe draws, together with timing metadata, before any encoder runs. This is the same design rule as for sliders. *Serialised form:* three parts: `frames`, every frame's data as canonical JSON, including anything that varies by frame such as a title; `style`, the static ggplot form of the first frame, which carries the theme, scales and labels; and `shell`, the timing metadata (frame count, frames per second, duration, easing) as canonical JSON. *States:* the first frame, the last frame, and N evenly spaced frames between them. N is declared by the case and defaults to 3. Playback is judged live on the review page.

**Trusting a fingerprint.** A fingerprint can go wrong in two directions. Keeping a status after a visible change is the failure that matters, and the design must rule it out. Resetting a status when nothing visible changed only costs review time, so it is allowed but should be rare. Four rules keep it that way:
1. **Completeness by construction.** The output is built from the object that is hashed, never from a parallel copy. A unit test per output type asserts this, for example that a widget's `x` equals its hashed payload.
2. **Sensitivity tests.** Per output type, unit tests change one input at a time (a coefficient, a slider range, a theme element, one byte of a shipped JS file) and assert the fingerprint changes.
3. **Stability tests.** Two builds in different temp folders and R sessions give the same fingerprint. Ticket 3 checks the same across platforms.
4. **Release audit.** The release check re-renders every state and compares it with the screenshot taken at approval on the same machine. A changed screenshot under an unchanged fingerprint means an input is missing from the serialised form, and is a suite bug.

A known false reset: rebuilding the slider payload from different reference rows can draw the same curves from different numbers. If this becomes common, a carry-over can be added later: R evaluates the old and new payloads at every reachable position (a random sample for three or more sliders), and keeps the status with an automated note when they agree within 1e-8. It is not built now.

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
- **H6, JSON:** canonical JSON (plotly figures, slider payloads, animation frames and every shell) matches across platforms. The only risk is H2 at 6 significant figures.
- **H7, versions not platforms:** most real mismatches will come from different package versions rather than operating systems. The experiment pins versions and records `sessionInfo()`, so each mismatch can be blamed on one or the other.

**Review status rules.** Encodes the decisions above. Trimmed from the logic prototype and corrected to the final model.

```
on run:
  expectations fail                 -> case fails; review untouched
  output fingerprint == recorded    -> keep review status
  output fingerprint != recorded    -> Unreviewed

Unreviewed       --agent approve (note required)--> Agent approved
Unreviewed       --agent reject  (note required)--> Rejected
Agent approved   --human approve-->                 Human approved
Agent approved   --human reject  (note)-->          Rejected
Rejected         --code changes fingerprint-->      Unreviewed
Platform variant of Human approved --agent approve (note)--> Human approved for that platform
```

The human never sees an Unreviewed output before an agent pass. This applies to interactive outputs too: agents review their sampled states.

**Review state storage.** Two dev-only files, both committed.
- `review_state.json` is written by the runner and the agent commands. Per judged output, it records the fingerprint, the hash of each serialised part, the runner's or agent's status, who set it, when, the agent note, and any agent rejection note. The screenshots of its states at the last approval are kept beside it.
- `human_decisions.json` is written only by the review server. Each entry is one human decision: output ID, the fingerprint judged, approve or reject, the note, and the date.

An output's review status is derived from both files. A human approval for the current fingerprint makes it Human approved. A human rejection for the current fingerprint makes it Rejected. Otherwise its status comes from `review_state.json`. A decision for an older fingerprint has no effect, so a changed output is Unreviewed again without anyone editing the decisions. A platform variant is likewise derived, from a human approval of the original fingerprint plus an agent approval of the variant, so agents never write the decisions file. `git log` on that file is the history of every human decision.

**Human authority.** Agents have no reason to write `human_decisions.json`, so a Claude Code hook can block every agent write to it by path, through file-edit and shell tools alike. This is a simple rule, with no need to inspect what an edit changes. One shared file couldn't be protected this way, because agents write it legitimately and a shell command's effect can't be seen in advance. The hook is a guardrail against careless or overeager agents, not a lock against a determined one. A forged decision would still show as a diff to that one file. If agents are ever run outside Claude Code, add a CI check on who changed it.

**Review page.** A small local server started from R (httpuv) serves the review page and records decisions. Layout from the review page prototype (v2):
- the suite overview (tiles by function family) is the default view (changed from the inbox at the Part B review, 2026-11-10);
- a collapsible sidebar groups cases by review status, with search, and the inbox of Agent approved outputs heads it;
- the page follows the system's light or dark setting;
- each case shows its expected behaviour, the agent note, any console diff, and a swipe or side-by-side comparison, or sampled states plus the live widget for interactive outputs;
- reject opens a note box with quick starter phrases;
- keyboard: j/k, a, r, s, o, [, and Ctrl+Enter;
- the URL deep-links to a case or to the overview.

**Screenshots.** Interactive states are captured with headless Chrome via chromote (dev-only), driven by a hook in the widget that sets a given state, so captures are deterministic. They are captured only for the states of Unreviewed outputs, never to compute a fingerprint. A state whose new screenshot is pixel-identical to the one kept from the last approval, on the same machine, is marked unchanged, so a reviewer can skip it; the changed parts of the serialised form say what to look for in the rest.

**CI.** A workflow runs on pushes to the test-suite branch only. It's used first by the cross-platform experiment. How CI maps review statuses to ✓/✗, and whether local fingerprints are authoritative across platforms, are **deferred to the experiment's result**. The working proposal: Rejected and Unreviewed fail, Agent approved warns, and a separate release check requires everything to be Human approved. The maintainer confirmed that Unreviewed fails (2026-11-09): an Unreviewed output reaching `main` is a failure, even if it means CI stays red until a review is done.

Partial results (October 2026, R 4.5.3, identical package versions on every machine). For plotly JSON, slider payloads, slider backgrounds and animation frames, GitHub's Windows and macOS runners matched the maintainer's machine exactly. Ubuntu (OpenBLAS) differed only where normalisation had a gap:
- plotly stores colorscale stops as strings, which `signif()` never reaches;
- the prototype slider's payload held device coordinates measured with system fonts, which the spec's data-unit payload already avoids.

Static plots, base graphics and condition text were not yet tested. The provisional reading: local fingerprints are authoritative on every platform once those gaps are closed. Ticket 3 confirms it on the new cases.

**Write, then salvage.** The new suite is a reinvention, not a migration. The old suite was deleted from the test suite branch before any new cases were written, and is kept only in the `old-suite` tag (the last `main` commit before the rewrite). It is read once, at the end, to check the new one, and is never used as a starting point. The work happens in four phases.

1. **Inventory.** A temporary **behaviour inventory** next to this spec records what each function must do, written from what the package says and does:
   - the roxygen docs, vignettes, README and glossary, for what each function is for and the plots that show it;
   - the dev docs, for decisions and known edge cases;
   - the source, where every condition raised and every branch on the kind of input is a candidate edge case.

   The `old-suite` tag is not read. The inventory uses a file format the review page reads, with a stable ID per behaviour. Cases cite the IDs they cover, so the page can show coverage, deferrals and each case's expected behaviour. For each function the inventory records:
   - **what the function must do**: its behaviours, stated as principles;
   - **the edge cases that come up**: each with the principle at stake, where it comes from, and workable options for testing it;
   - **shared behaviours** that cut across functions (input validation, back-transforms, imputation, facet/group slicing), so each is tested once.

2. **Write by test type.** New cases are written from scratch from the inventory, split by test type, not by function:
   - **numeric** expectations;
   - **condition** expectations, with message wording as judged outputs;
   - **static appearance** judged outputs;
   - **interactive** states.

   Each test type is written across every function the inventory lists, and nothing written in this phase reads the old suite.

3. **Salvage audit.** With the new suite written, one session reads the `old-suite` tag (without restoring it to the branch) and goes through every old case and asks what kind of situation it put the function in: model shapes, argument forms, plot contexts, numeric boundaries, text and layout, conditions from dependencies, and platform fixes, plus the real student models in the archive. Each old case is logged as covered (by a named new case), added, or discarded with a reason. Old infrastructure, reference-image details and old wording are discarded by default. A gap goes into the inventory as a principle first and is then written as a new case by its test type's rules. No old code or wording is copied.

4. **Clean up.** The inventory and the audit log are deleted, and the maintainer decides whether to keep the tag.

The backend and the review page come before all four phases, so the maintainer reads the inventory and the cases in the review page. Tickets: `for_devs/tickets/README.md`.

**Documentation.** The tests README is rewritten as the guide for adding features and output types to the suite. The test-suite iteration loop in `CLAUDE.md` is replaced by a short pointer to that guide. It may become a skill later.

## Testing Decisions

- A good test asserts external behaviour at the highest seam: what data a plot will draw, what condition a user sees. Never private helpers or drawing internals.
- The suite's own infrastructure (fingerprint normalisation, review status transitions, the review server's write rules) gets ordinary unit tests, because it is deterministic. Each output type also gets the completeness, sensitivity and stability tests from *Trusting a fingerprint*.
- The review status rules are tested as a pure function of (recorded state, new fingerprint, action) → new state, laid out row for row against the transition table above.
- Completeness, sensitivity and stability tests are written once against the output-type contract. Each type supplies its own "change one input" mutations.
- **Testing the tests.** A mutation check applies known breaks to a temporary copy of the suite, one at a time, and reports which ones the unit tests catch. For example: a changed fingerprint keeps its status, a part is dropped, normalisation is skipped, or an agent writes Human approved. Every break must be caught. The review page shows the latest report, so the maintainer can trust the backend without reading its tests.
- Expectations must finish in about a minute in total and use two threads or fewer. Anything needing a browser or network is skipped on CRAN.

## Out of Scope

- Migrating old cases one-for-one, or preserving any old `# EXPECT:` wording.
- Vignette figures as judged outputs (later ticket).
- Turning the guide into a skill.
- Building the slider, plotly-preset and animation features themselves; only prototype outputs of them are used by the experiment. Their cases are added once the features exist, each by registering an output type.
- Changes to the CRAN R CMD check workflow on `main`.

## Further Notes

- Prototype: `for_devs/prototypes/review_page_v2.html`, the accepted review page layout. The superseded logic-ladder prototype was not kept.
- Decided locations: this spec, the temporary behaviour inventory and the salvage audit log live in `for_devs/`; tickets live in `for_devs/tickets/`, because issues are disabled on the repository.
- The work happens on a dedicated branch. Until ticket 2 lands, R CMD check on it covers little, so package code changes belong on `main`.
