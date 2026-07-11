# CLAUDE.md — Developer Guide for Claude Code

## Running Tests

The test suite lives in `testing/` — full docs in `testing/README.md`. One
case = one `.R` file in `testing/cases/`; the terminal runner and the human
HTML report (`testing/report.Rmd`) both execute those same files.

Run from the package root:

```sh
Rscript testing/run.R            # all cases
Rscript testing/run.R gs_14      # one case (prefix is enough)
Rscript testing/run.R gs         # all geom_slice cases
```

- **Visual cases** (e.g. `gs_*`) save `testing/output/<id>.png`.
- **Console cases** (`err_*`, `le_*`) save `testing/output/<id>.txt` and are
  diffed automatically against `testing/expected/<id>.txt`.

Each `gs_` case has a matching **reference image** in `testing/reference/` —
the ground-truth plot built independently of `geom_slice` (plain ggplot2 +
`predict()`, no Applr, no `geom_smooth()`). `testing/reference/<id>.png` is
what a correct `geom_slice` should reproduce. Regenerate with
`Rscript testing/reference/build_all.R` (rarely needed — only when a case's
data, model, or styling changes).

### Iteration loop (geom_slice work)

1. Run the case with `Rscript testing/run.R gs_XX`
2. **If it FAILs** — read the error message, find the relevant source in `R/geom_slice.R`, fix it, re-run
3. **If it's OK** — use the `Read` tool to view BOTH the output (`testing/output/gs_XX_name.png`) and its reference (`testing/reference/gs_XX_name.png`)
4. Compare the output against the reference image (the ground truth) and the `# EXPECT:` header at the top of the case file — line shape, slopes, per-group/per-facet positions, and styling should match the reference
5. **If the plot looks wrong** — fix the source, re-run, re-view
6. Move to the next case in order (gs_01 → gs_02 → ... → gs_18)
7. When complete, run `Rscript -e "rmarkdown::render('testing/report.Rmd')"` for human review of your work

An `OK` from the runner only means the case ran and produced a plot — step 3's
visual comparison is what decides correctness. When editing or adding cases,
follow the case-file anatomy in `testing/README.md` (structured `# CASE:` /
`# TYPE:` / `# FUNC:` / `# EXPECT:` header, `source("testing/_setup.R")` first,
no `ggsave()` — the runner renders).
