# Applr Test Suite

One test case = one `.R` file in `cases/`. The same files are consumed by two
renderers, so the terminal suite and the human report can never drift apart:

| Entry point | Audience | What it does |
|---|---|---|
| `Rscript testing/run.R` | AI / terminal | Runs cases, saves PNGs / captures console output, prints OK/FAIL |
| `Rscript -e "rmarkdown::render('testing/report.Rmd')"` | Human | Knits every case into a tabbed HTML report with reference images inline |

Run everything **from the package root**, not from `testing/`.

## Directory layout

```
testing/
├── README.md      <- this file
├── _setup.R       <- shared setup: loads the package, defines try_show() and
│                     parse_case_header(). Sourced as the first line of every case.
├── run.R          <- terminal runner (see usage below)
├── report.Rmd     <- human report; auto-discovers cases/, knit to report.html
├── cases/         <- THE test suite (single source of truth)
├── reference/     <- ground-truth images for gs_ cases + the scripts that build them
├── expected/      <- expected console output (.txt) for console cases
├── output/        <- generated results (gitignored)
├── archive/       <- old Comparison.Rmd, dated report snapshots, misc review files
└── student_models_house_selling_prices/  <- student HTMLs kept for reference (not tests)
```

## Running tests

```sh
Rscript testing/run.R                  # run every case
Rscript testing/run.R gs_01            # run one case (prefix is enough)
Rscript testing/run.R gs err           # run all gs_* and err_* cases
Rscript testing/run.R --update err_01  # accept current console output as the new snapshot
```

- **Visual cases** save `output/<id>.png`. The runner only checks that the
  case ran and produced a plot — *correctness* is judged by comparing the PNG
  against `reference/<id>.png` (where one exists) and the case's `EXPECT`
  header. (If a case accidentally draws more than one plot, numbered
  `<id>-01.png`, `<id>-02.png`, ... appear — treat that as a case to split.)
- **Console cases** save `output/<id>.txt` and are diffed automatically against
  `expected/<id>.txt`. A case with no snapshot yet reports `NEW`; review its
  output, then run with `--update` to accept it as the baseline.
- **Known-broken cases:** a case whose `EXPECT` header says `KNOWN ISSUE`
  documents a real, currently-unfixed bug. It FAILs on purpose — the runner's
  FAIL list doubles as the open-bug list — and turns OK once the bug is fixed.

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

source("testing/_setup.R")   # always the first code line
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
| `gf_` | `geom_fit` | visual |
| `s2_` | `slice_2d` | visual |
| `as_` | `add_slice_2d` | visual |
| `dw_` | `drawit` | visual |
| `ga_` | `geom_add_slice_2d` | visual |
| `ap_` | `autoplot.lm` (the geom_slice × autoplot interface, not full geom_slice coverage) | visual |
| `le_` | `lm_equation` | console |

**Error cases live under their function's prefix** with `err` in the slug
(e.g. `s2_16_err_nonexistent_xaxis`, `gf_24_err_non_lm`), not in a shared
"error" family. That keeps everything about one function — happy paths and
misuse handling — under one prefix, so `run.R gf` shows an agent working on
`geom_fit` only geom_fit behavior, with no other function's errors as noise.
Error cases are numbered after the happy-path cases of their function.

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
Rscript testing/reference/build_all.R
```

Only needed when a case's data, model, or styling changes.
