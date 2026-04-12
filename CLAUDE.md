# CLAUDE.md — Developer Guide for Claude Code

## Running Plot Tests

Each test case in `testing/cases/`:
1. Loads the current saved package state with `devtools::load_all(".")`
2. Renders one plot
3. Saves it to `testing/output/<name>.png`

### Iteration loop

1. Run the test with `Rscript testing/cases/gs_XX_name.R`
2. **If it errors** — read the error message, find the relevant source in `R/geom_slice.R`, fix it, re-run
3. **If it saves successfully** — use the `Read` tool on the PNG path to view the plot visually
4. Compare the plot against the `# EXPECT:` comment at the top of the test file
5. **If the plot looks wrong** — fix the source, re-run, re-view
6. Move to the next test in order (gs_01 → gs_02 → ... → gs_16)
