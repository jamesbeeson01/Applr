# Prompt C — Roxygen docs pass on the geom_slice family + autoplot

Paste everything below into a fresh Claude Code session at the package root.

---

You are doing a documentation-only pass on Applr's flagship functions for the
v1.0 release (plan in `for_devs/release_plan_1.0.md`). Other sessions are
editing other files in parallel, so stay strictly inside your scope.

**Scope — you may edit ONLY these files:**
- `R/geom_slice.R`
- `R/geom_slice_caption.R`
- `R/geom_slice_subtitle.R`
- `R/geom_slice_text.R`
- `R/autoplot.lm.R`

**Do NOT:** run `devtools::document()`, edit `NAMESPACE`, `man/`,
`DESCRIPTION`, or any other `R/` file (`R/deprecated.R`, `R/slice_2d.R`, and
the utility files are owned by other sessions). Do not
change any function's behavior or signature — roxygen comments only.

**Task:** these are the functions users meet first, so the docs must show the
RANGE of what each can do. The test cases are your example catalog: read
`testing/cases/gs_*.R` and `ap_*.R` — each has a structured header describing
what it exercises.

For each exported function in scope:
1. `@title`, `@description` (what it does + when to use it), complete
   `@param` docs, `@return` (CRAN requires it), `@seealso` cross-links within
   the family, and `@examples`.
2. `geom_slice()` examples should demonstrate at least: the basic
   `geom_smooth`-like usage; `predict_vars` (single and multi-value —
   crossed lines); `interval = "confidence"` / `"prediction"`; grouping via
   `aes(color = )`; faceting; a transformed response
   (`lm(log(y) ~ ...)` back-transformed automatically) and the
   `back_transform` argument; `n`.
3. `autoplot.lm()` examples: minimal `autoplot(model)`, choosing the x axis,
   forwarding args to `geom_slice` via `...`.
4. The caption/subtitle/text helpers: one example each showing them composed
   with `geom_slice()` on the same plot.
5. Examples must use built-in datasets, run unattended in a few seconds, and
   be verified with `Rscript -e "devtools::load_all('.'); <example code>"`.
   Note: `geom_slice` prints console messages about imputed values — that is
   expected, not an error.
6. Document the ggproto objects (`GeomSlice`, `StatSlice`, etc.) with the
   standard one-paragraph "internals, see geom_slice()" pattern if their
   roxygen blocks are thin.
7. Follow the message/error format standards in `for_devs/decisions.Rmd` when
   describing behavior. If you spot code issues, do NOT fix them — list them
   in your final summary.

When done, summarize per-file what you added and list any discrepancies
between existing docs and actual behavior.
