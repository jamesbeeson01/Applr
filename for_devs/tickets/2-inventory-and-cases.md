# 2: Behaviour inventory and cases

**What to build:** A principle-based behaviour inventory of what each exported function must do, written from the docs and the source. Then, from it, every case: numeric expectations, condition expectations with their wording as judged outputs, static appearance outputs, and `scatter_3d`'s interactive outputs. Each case gets an agent first pass and ends up in the maintainer's queue.

**Done when:** every behaviour in the inventory is covered by a case or deferred with a reason; all expectations pass under R CMD check within the time budget; and every judged output is Agent approved with a note and waiting in the review page.

**Blocked by:** 1

**Status:** ready-for-agent

## Never read the old suite

The old suite exists only in the `old-suite` tag, and only ticket 4 reads it. Some dev docs mention old case IDs (`gs_09`, `sb_15` and so on). Take the principle from the note itself and don't look the case up. Don't use `for_devs/experiments/` as a source either.

## Step 1: inventory. Pause for the gist.

Sources:
- the roxygen docs (`R/*.R`, `man/`), the vignettes, `README.Rmd` and `GLOSSARY.md`, for what each function is for, and the plots that show it;
- the dev docs (`for_devs/knowledge_base.Rmd`, `decisions.Rmd`, `known_issues.Rmd`, `testing_revisions.md`), for decisions and known edge cases;
- the source in `R/`, for edge cases: every condition raised, and every branch on the kind of input (factor or numeric, transformed or not, data given or not).

The inventory lives in `for_devs/`, in the format ticket 1 defined, and is marked temporary at the top. For each exported function it records:
- [ ] what the function must do, stated as principles;
- [ ] its edge cases, each with the principle at stake, where it comes from (doc, decision, or source line), and how it can be tested;
- [ ] the doc and vignette plots that show its purpose, as the starting point for its appearance outputs.

Across all functions:
- [ ] shared behaviours (input validation, back-transforms, imputation, facet and group slicing, held values) are pulled out, so each is tested once;
- [ ] each behaviour is tagged with its test type: numeric, condition, static appearance or interactive.

- [ ] **Pause.** Give the maintainer the gist in chat:
  - the functions covered;
  - the shared behaviours pulled out;
  - the count of behaviours per test type;
  - the edge cases most likely to matter;
  - anything you were unsure how to classify.

  Wait for a go-ahead. Don't ask for a line-by-line review: the maintainer reads the details in the review page's inventory view.

## Step 2: cases, by test type

Write each test type across every function, not function by function. Every case cites the inventory IDs it covers.

- [ ] **Numeric.** Plotted lines, bands, intervals and held values are compared against `predict()` on a grid the test builds itself. Read them at the highest seam: built layer data, prepared slice data, built plotly traces. The prediction function is trusted, not tested.
- [ ] **Condition.** Errors, warnings and messages are checked by class and key fields, plus "a plot is still built" wherever the behaviour calls for it. Each message's wording is a judged output, and follows the two-part condition format in `for_devs/decisions.Rmd`.
- [ ] **Static appearance.** Only behaviours that can't be stated as expectations become appearance outputs: labels fitting, wrapping, legends, facets, styling. Each output's expected behaviour says *what* to see first, with an optional *why*.
- [ ] **Interactive.** `scatter_3d` with camera presets. Slider and animation cases wait until those features exist. If you want to ship them, register them as new output types (ticket 1's contract); don't special-case them.
- [ ] Any behaviour not covered is marked deferred in the inventory, with its reason.
- [ ] All expectations together finish in about a minute and use two threads or fewer. Anything that needs a browser is skipped on CRAN.
- [ ] Agent first pass on every judged output, using its sampled states for interactive ones, each with a note. Everything ends Agent approved and waiting in the maintainer's queue.

If the inventory turns out too large for one session, stop after a finished test type and say where to pick up. Don't split it in advance.
