# Applr Test Suite

This test suite gives both humans and coding agents access to information about the package's current state. 

Note to agents: When finished running tests, render report.Rmd for human review.

One test case = one `.R` file in `cases/`. There is exactly **one** executor
of cases — `run.R` — so the terminal suite and the human report can never
drift apart:

| Entry point | Audience | What it does |
|---|---|---|
| `Rscript tests/run.R` | AI / terminal | Runs cases, saves PNGs / captures console output, prints OK/FAIL |
| `Rscript -e "rmarkdown::render('tests/report.Rmd')"` | Human | Invokes `run.R` once (fresh Rscript session), then lays out that run's artifacts — status, source, output PNG, captured console output, reference image — as a tabbed HTML report |

The report never executes case code in the knitting session and never loads
the package (it sources only `_helpers.R`), so it cannot show anything other
than what `run.R` produced, regardless of what is loaded in the session that
knits it.

Run everything **from the package root**, not from `tests/`.

## Directory layout

```
tests/
├── README.md      <- this file
├── _setup.R       <- shared setup: loads the package, defines try_show().
│                     Sourced as the first line of every case.
├── _helpers.R     <- package-free helpers (parse_case_header); used by both
│                     _setup.R and report.Rmd
├── run.R          <- terminal runner, the ONLY executor of cases (see usage below)
├── report.Rmd     <- human report; runs run.R once and displays its artifacts
├── testthat.R     <- standard R-package test entry point (see "The testthat shim")
├── testthat/      <- test-suite.R: thin shim that runs run.R via testthat
├── cases/         <- THE test suite (single source of truth)
├── reference/     <- ground-truth images for gs_ cases + the scripts that build them
├── expected/      <- expected console output (.txt) for console cases and for
│                     any visual case that intentionally prints/messages
├── output/        <- generated results (gitignored)
├── archive/       <- old Comparison.Rmd, dated report snapshots, misc review files
└── student_models_house_selling_prices/  <- student HTMLs kept for reference (not tests)
```

## Running tests

```sh
Rscript tests/run.R                  # run every case
Rscript tests/run.R gs_01            # run one case (prefix is enough)
Rscript tests/run.R gs err           # run all gs_* and err_* cases
Rscript tests/run.R --update gs_02   # accept current console output as the new snapshot
```

- **Visual cases** save `output/<id>.png`. The runner only checks that the
  case ran and produced a plot — *correctness* is judged by comparing the PNG
  against `reference/<id>.png` (where one exists) and the case's `EXPECT`
  header. (If a case accidentally draws more than one plot, numbered
  `<id>-01.png`, `<id>-02.png`, ... appear — treat that as a case to split.)
- **Visual cases also capture console output** (messages, warnings, printed
  values) to `output/<id>.txt`, diffed against `expected/<id>.txt` exactly
  like a console case. A visual case with no `expected/` snapshot must be
  *silent*: unexpected output reports `NEW` (review it, then `--update` to
  accept or fix the source to silence it), a snapshot mismatch is a `FAIL`,
  and a snapshot with no output is a `FAIL`. So every visual case tests its
  plot AND its console behavior — no duplicate text-only case needed.
- **Console cases** save `output/<id>.txt` and are diffed automatically against
  `expected/<id>.txt`. A case with no snapshot yet reports `NEW`; review its
  output, then run with `--update` to accept it as the baseline.
- **Known-broken cases:** a case whose `EXPECT` header says `KNOWN ISSUE`
  documents a real, currently-unfixed bug. It FAILs on purpose — the runner's
  FAIL list doubles as the open-bug list — and turns OK once the bug is fixed.

## The testthat shim (`testthat.R` + `testthat/test-suite.R`)

`tests/` is also the standard R-package test directory, and the two testthat
files here exist purely so the standard tooling finds something to run:
`devtools::test()` and `R CMD check` execute `testthat/test-suite.R`, which
shells out to `Rscript tests/run.R` and converts its per-case results into
testthat expectations. It contains **no test logic of its own** — `run.R` and
`cases/` remain the single source of truth, and the shim can never drift from
them.

Everything in `tests/` *except* the two testthat files is `.Rbuildignore`'d,
so the built tarball ships only the shim; on the tarball (`R CMD check`) the
shim detects that `run.R` is absent and skips. It runs for real only from a
source checkout (locally and in the CI `case-suite` job). An OK from the shim
means every case ran and matched its console snapshot — the visual comparison
against `reference/` images is still a human step via `report.Rmd`.

## Case file anatomy

**One case = one plot (or one console scenario) = one purpose.** Don't bundle
several plots or several behaviors into one file — make another case instead;
`run.R <prefix>` already runs whole families in one go. (A single plot with
several layers, like three slices on one scatter, is still one case.)

```r
# CASE: gs_01_single_predictor              <- must match the filename
# TYPE: visual                              <- visual | console
# FUNC: geom_slice                          <- groups cases in the report
# SIZE: 10x4                                <- optional plot size in inches (default 7x5)
# EXPECT: One straight line, slope ~1.      <- what a CORRECT result looks like;
#         Continuation lines are indented.     shown in the report and on failure

source("tests/_setup.R")   # always the first code line
set.seed(123)                # each case owns its data + seed (see note below)

# ... build data and model ...

p <- ggplot(...) + geom_slice(model)
p                            # visual case: end by printing the ONE plot
```

Console cases instead make ONE call, wrapped in `try_show()` (defined in
`_setup.R`), which prints the result or the error/warning/message it raises
as ordinary text — so an *expected* error is captured in the snapshot instead
of aborting the case:

```r
try_show(slice_2d(not_a_model))
```

Cases must **not** call `ggsave()`, `png()`, or `dir.create()` — the runner and
the report handle rendering. Base-graphics plots (`plot()`, `slice_2d()`, ...)
work the same as ggplots: just make the plot; the open device captures it.

**Why each case generates its own data:** deleting or editing one case can
never affect another, and the `gs_` reference images stay valid (they were
built from each case's exact seed + RNG call sequence — don't reorder the
data-generation lines of a `gs_` case without regenerating its reference).

## Naming convention

`<prefix>_<NN>_<slug>.R` — prefix = what's under test, NN = run order, slug = scenario.

| Prefix | Function under test | Type |
|---|---|---|
| `gs_` | `geom_slice` (granular; each has a reference image) | visual |
| `s2_` | `slice_2d` | visual |
| `as_` | `add_slice_2d` | visual |
| `ap_` | `autoplot.lm` (the geom_slice × autoplot interface, not full geom_slice coverage) | visual |
| `le_` | `lm_equation` | console |
| `la_` | `lm_latex` | console |

**Error cases live under their function's prefix** with `err` in the slug
(e.g. `s2_16_err_nonexistent_x_axis`, `gs_27_err_non_lm`), not in a shared
"error" family. That keeps everything about one function — happy paths and
misuse handling — under one prefix, so `run.R s2` shows an agent working on
`slice_2d` only slice_2d behavior, with no other function's errors as noise.
Error cases are numbered after the happy-path cases of their function.
Use `err` in the slug only when the case actually raises an error; when the
misuse is handled by warning and skipping (e.g. `geom_slice_subtitle()` with
no slice layer), name the slug `warn` instead so the name matches the
behavior.

## Adding / removing a case

- **Add:** drop a new `.R` file in `cases/` following the anatomy above. Done —
  both the runner and the report discover it automatically. For a console case,
  run it once, review `output/<id>.txt`, then `--update` to create the snapshot.
- **Remove:** delete the file (and its `expected/` or `reference/` counterparts
  if any). Nothing else references it.

## Reference images (`reference/`)

Ground truth for the `gs_` cases, built **without** Applr (plain ggplot2 +
`predict()`, no `geom_smooth()`). `reference/<id>.png` is what a correct
`geom_slice` should reproduce. Regenerate with:

```sh
Rscript tests/reference/build_all.R
```

Only needed when a case's data, model, or styling changes.
