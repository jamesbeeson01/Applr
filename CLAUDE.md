# CLAUDE.md — Developer Guide for Claude Code

## Running Plot Tests

Each test case in `testing/cases/`:
1. Loads the current saved package state with `devtools::load_all(".")`
2. Renders one plot
3. Saves it to `testing/output/<name>.png`

Each test has a matching **reference image** in `testing/reference/` — the
ground-truth plot built independently of `geom_slice` (plain ggplot2 + `predict()`,
no Applr, no `geom_smooth()`). `testing/reference/<name>.png` is what a correct
`geom_slice` should reproduce. Regenerate them with
`Rscript testing/reference/build_all.R` (rarely needed — they only change if a
test's data, model, or styling changes).

### Iteration loop

1. Run the test with `Rscript testing/cases/gs_XX_name.R`
2. **If it errors** — read the error message, find the relevant source in `R/geom_slice.R`, fix it, re-run
3. **If it saves successfully** — use the `Read` tool to view BOTH the output (`testing/output/gs_XX_name.png`) and its reference (`testing/reference/gs_XX_name.png`)
4. Compare the output against the reference image (the ground truth) and the `# EXPECT:` comment at the top of the test file — line shape, slopes, per-group/per-facet positions, and styling should match the reference
5. **If the plot looks wrong** — fix the source, re-run, re-view
6. Move to the next test in order (gs_01 → gs_02 → ... → gs_18)
