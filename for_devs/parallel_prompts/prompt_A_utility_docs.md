# Prompt A — Roxygen docs pass on utility functions

Paste everything below into a fresh Claude Code session at the package root.

---

You are doing a documentation-only pass for the Applr v1.0 release (plan in
`for_devs/release_plan_1.0.md`). Other sessions are editing other files in
parallel, so stay strictly inside your scope.

**Scope — you may edit ONLY these files:**
- `R/theme_lc.R`
- `R/lm_equation.R` (documents `lm_equation` and `lm_latex`)
- `R/scatter_3d.R`
- `R/diagnose.R`
- `R/get_inverse_function.R`

**Do NOT:** run `devtools::document()`, edit `NAMESPACE`, anything in `man/`,
`DESCRIPTION`, or any other `R/` file (especially `R/deprecated.R` and the
`geom_slice*` family — other sessions own those).
Do not change any function's behavior or signature — roxygen comments only.

**Task, for each exported function in scope:**
1. Ensure a clear `@title` and a `@description` that says what the function
   does and when a user would reach for it.
2. Add `@return` describing the return value (CRAN requires this).
3. Write `@examples` that show the RANGE of what the function can do — not
   one minimal call. Use built-in datasets (`mtcars`, `iris`, `palmerpenguins`
   is NOT available — stick to base datasets). Examples must run unattended
   in a few seconds. Wrap plotly/interactive output (`scatter_3d`) in
   `if (interactive()) { ... }`.
4. Verify every example actually runs:
   `Rscript -e "devtools::load_all('.'); <example code>"`.
5. `get_inverse_function` is NOT exported — replace its roxygen block's
   public-facing tags with `@noRd` (keep the explanatory comments) so it
   stops generating a public help page.
6. Match the error-message/naming standards in `for_devs/decisions.Rmd` when
   describing behavior; do not "fix" code even if you spot issues — instead
   list them at the end of your final summary.

When done, summarize per-file what you added and paste any issues you noticed
but did not touch.
