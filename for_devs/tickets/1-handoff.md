# Handoff: ticket 1, paused at the Part A review

**Status (2026-11-09):** Part A (backend) is built and waiting for the maintainer's approval. Part B (review page) has not started and must not start until the maintainer approves. Nothing is committed: all of this is uncommitted work on `test-suite-revision`, in this checkout.

Read first: `1-backend-and-interface.md` (the ticket), `tests/suite/README.md` (the contract, written for the review), and the spec's *One contract per output type* and *Trusting a fingerprint* sections.

## What the maintainer reviews

The ticket's pause asks for three things:

1. **The contract:** the *Output types* section of `tests/suite/README.md`.
2. **The fake-type test:** `tests/suite/unit/test-fake-type.R`. It defines a travel itinerary type (four parts, five states, an HTML view per state) in that file only, and takes it through run → fingerprint → states → agent approval → `review_page_data()`. It then runs the shared completeness, sensitivity and stability tests on it.
3. **The mutation report:** `tests/suite/mutation_report.json`, or the table printed by `Rscript tests/suite/mutate.R`. **21 of 21 breaks caught**, and the unbroken suite passes all 40 test blocks. One earlier run missed "compute steps run without the pinned options": testthat already sets most of those options, so the old test passed regardless. The test now sets the opposite values first, and the final run caught that break.

Judgment calls the maintainer should confirm:

- **The numeric-string rule** (spec, *Canonical JSON*, now updated). A string that is entirely a decimal number with a fractional part or an exponent is rounded to 6 significant figures and stays a string. Integer-looking strings are left alone. It lives in canonical JSON rather than in the plotly type, so future types get it too. It hasn't yet been re-checked on Ubuntu; ticket 3 does that.
- **A function needs `type =`.** Detection only claims ggplots (`static_plot`) and plotly widgets (`plotly_3d`). A function could be base-graphics drawing code or a call whose conditions are judged, so the case must say which.
- **Views come from the hashed build.** `serialise()` returns a `view`, and `render()`/`live()` draw only from it. Completeness is tested by tagging each view with its output's fingerprint and checking that every rendered file carries the right tag.
- **The core runs the common normalisation on every part**, so no type can skip it. Types add only their own rules.
- **Each plotly live page has its own `lib/` folder**, so plotly.js (~3.5 MB) is copied once per widget, in the gitignored `tests/output/`. `htmlwidgets::saveWidget()` refuses a shared lib folder outside the page's own folder.
- **The fake type doesn't hash its states**, since for it they are only views. plotly does hash its camera presets, as the spec says.

## What was built

| File | What it is |
|---|---|
| `tests/suite/types.R` | The contract: `register_output_type()`, `output_type()`, `resolve_output_type()` (the one place a type is worked out), `serialise_output()` |
| `tests/suite/types/*.R` | One registration per type: `static_plot`, `base_graphics`, `conditions`, `plotly_3d` |
| `tests/suite/views.R` | PNG device, live widget pages, chromote screenshots through `window.applrSetState`, `render_views()` |
| `tests/suite/store.R` | `run_suite()` → `apply_case()` (generic over types); `keep_approved_views()`; `review_page_data()`, the data Part B's page reads |
| `tests/suite/fingerprint.R` | Added `svg_form()` and `canonical_json()` with the numeric-string rule; removed the static-plot serialiser |
| `tests/suite/load.R` | `load_suite(dir)` sources the core and every type; a copy of the suite loads its own files |
| `tests/suite/mutate.R` | The mutation check: 21 breaks, each applied to a temp copy, with the unit tests run 4 copies at a time |
| `tests/testthat/helper-judged.R` | `judged_output(name, object, type = NULL, states = NULL)`, still a no-op under R CMD check |
| `tests/testthat/test-case_*.R` | Demo cases: `single_predictor_line` (static, fingerprint unchanged at `cda9191215fe`), `base_slice_2d`, `condition_imputed_values`, `scatter_3d_two_predictors` |
| `tests/suite/unit/helper-contract.R` | `expect_complete()`, `expect_sensitive()`, `expect_stable()`, written once against the contract |
| `tests/suite/unit/test-contract.R` | Runs those three on every registered type |
| `tests/suite/unit/test-status.R` | Transition tests as a table, one block of rows per row of the spec's table |
| `tests/suite/unit/test-types.R` | Type resolution, state names, normalisation of every part, and "the core never names a type" |

`test-static-trust.R` was deleted; its tests moved onto the shared contract tests. `review_state.json` and `forms/` now hold all four demo outputs, all Unreviewed. Rendered views are in `tests/output/` (gitignored).

## Results

- `Rscript tests/suite/test.R`: all pass (40 test blocks), in about 2 minutes. Most of that time goes to the stability tests (fresh R sessions) and the plotly screenshots.
- `Rscript tests/suite/mutate.R`: about 20 minutes, because each break needs a full unit test run. The maintainer was told it could be made faster by stopping each run at its first failing test; they haven't asked for that.
- The screenshots were checked by eye: the plotly `top`/`side`/`default` states show the surface from different cameras, and the base graphics PNG shows the slice.

## Problems found along the way

- **Chrome timeouts under load.** With several R processes running, Chrome took longer than chromote's 10-second default to load the widget page, and the plotly completeness test failed. `views.R` now sets `options(chromote.timeout = 60)` when it creates the session, and uses 60 seconds for the page-load and evaluate waits. 20 of 20 renders passed with 5 running at once.
- **A possible package bug, not fixed (outside this ticket):** `geom_slice(lm(mpg ~ wt + hp + factor(cyl), mtcars))` imputes `cyl` with its *mean* (6.188), because `all.vars()` sees the raw numeric `cyl`. `predict()` then fails: `factor factor(cyl) has new level 6.1875`. The conditions demo now uses `qsec` to avoid it. This should go to the maintainer as a package issue on `main`.

## Gotchas for the next session

- Never pass multi-line R through `Rscript -e` on Windows. Write a script file instead.
- Avoid writing R regexes through Python or bash heredocs: backslashes got mangled several times. Use the file-edit tool.
- `mutate.R` writes the generated runner scripts with forward-slash paths. Backslash paths broke R strings (`'\U' used without hex digits`).
- testthat's own options hide gaps in pinned options. Any test of an option must set the opposite value first.

## Next: Part B, after approval

Follow the ticket's Part B list. Starting points:

- `review_page_data(paths)` in `store.R` already gives everything per output: view kind, states with current and approved files, live page, form paths, notes, status. Serve it from httpuv, and add a server-only write path for `human_approve`/`human_reject` that goes through `review_transition()`.
- The accepted layout is `for_devs/prototypes/review_page_v2.html`.
- The mutation report and unit test results for the suite health view: `mutation_report.json`, plus a JSON of the latest `test.R` run (not written yet).
- Add a break to `mutate.R` for each new server rule, such as "the server accepts a human reject without a note".
- The human-authority hook goes in `.claude/settings.json`, which today only allows commands for the old suite (`tests/run.R`, `tests/report.Rmd`) that no longer exist. Those entries are stale.
