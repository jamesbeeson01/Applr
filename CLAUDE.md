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

- **Visual cases** (e.g. `gs_*`) save `testing/output/<id>.png`. Any console
  output they emit is also captured to `testing/output/<id>.txt` and diffed
  against `testing/expected/<id>.txt`; with no snapshot, the case must be
  silent.
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
2. **If it FAILs** — read the message: it is either an R error (find the relevant source in `R/geom_slice.R`, fix it, re-run) or a console-output diff against `testing/expected/gs_XX_name.txt` (decide whether the code or the snapshot is wrong)
3. **If it's NEW** — the case printed console output that has no snapshot yet; read `testing/output/gs_XX_name.txt`, and only if the output is correct and intentional, accept it with `Rscript testing/run.R --update gs_XX` (never blanket-update)
4. **If it's OK** — use the `Read` tool to view BOTH the output (`testing/output/gs_XX_name.png`) and its reference (`testing/reference/gs_XX_name.png`)
5. Compare the output against the reference image (the ground truth) and the `# EXPECT:` header at the top of the case file — line shape, slopes, per-group/per-facet positions, and styling should match the reference
6. **If the plot looks wrong** — fix the source, re-run, re-view
7. Move to the next case in order (gs_01 → gs_02 → ... → gs_18)
8. When complete, run `Rscript -e "rmarkdown::render('testing/report.Rmd')"` for human review of your work

An `OK` from the runner means the case ran, produced a plot, and its console
output (if any) matched its snapshot — step 4's visual comparison is what
decides plot correctness. When editing or adding cases,
follow the case-file anatomy in `testing/README.md` (structured `# CASE:` /
`# TYPE:` / `# FUNC:` / `# EXPECT:` header, `source("testing/_setup.R")` first,
no `ggsave()` — the runner renders).
