# Prompt B — README refresh

Paste everything below into a fresh Claude Code session at the package root.

---

You are refreshing `README.md` for the Applr v1.0 release (plan in
`for_devs/release_plan_1.0.md`). Other sessions are editing `R/` files in
parallel, so stay strictly inside your scope.

**Scope — you may edit ONLY `README.md`.** Read anything you like
(especially `R/geom_slice.R`, `R/geom_slice_caption.R`,
`R/geom_slice_subtitle.R`, `R/geom_slice_text.R`, `R/autoplot.lm.R`,
`R/slice_2d.R`, and `testing/cases/gs_*.R` / `ap_*.R` for real working
examples of the current API). Do NOT run `devtools::document()` or edit any
`R/` file.

**Tasks:**
1. Update all code examples to the CURRENT API. The `geom_slice` examples are
   known-stale (`for_devs/dev_todo.Rmd`). Verify each snippet actually runs:
   `Rscript -e "devtools::load_all('.'); <snippet>"`.
2. Remove the `drawit()` section — it is deprecated (a shim that forwards to
   `slice_2d()`). Mention it only in a one-line "deprecated" note if at all.
3. Remove or fix the `geom_fit` references if any exist (it is already a
   deprecated error stub).
4. Add sections/examples for the newer functions the README doesn't cover:
   `autoplot()` for lm objects, `geom_slice_caption()`,
   `geom_slice_subtitle()`, `geom_slice_text()`, `interval =` on
   `geom_slice()`, multi-value `predict_vars`, and `diagnose()` if exported
   behavior warrants it.
5. Make the "Getting help" section link to the actual GitHub repo
   (`https://github.com/saundersg/Applr`) for issues.
6. Keep the friendly teaching tone; keep the Quick start near the top short.

When done, summarize what changed and flag any README claims you could not
verify against the code.
