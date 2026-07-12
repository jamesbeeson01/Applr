# Applr v1.0 Release Plan

Written 2026-07-12. The single gate for "release-worthy" is a clean
`devtools::check()` — `document()` alone is not the finish line. Work is
ordered so that API-breaking decisions land first, docs second, packaging
mechanics third.

## Guiding principle

v1.0 is an API stability promise. Anything that renames or removes a public
function/argument must happen **before** the 1.0 tag (free to break) — after
it, every rename costs a full deprecation cycle. Purely additive features
(`full_range`, legend intervals, `data`/aes args on `geom_slice`) can safely
land in 1.1+.

## Phase 0 — Decisions (RESOLVED 2026-07-12)

All Phase 0 decisions are settled; the outcomes are baked into the codebase.

1. **Final public names.** `slice_2d`, `geom_slice`, and `x_axis` are the names
   we ship; the snake_case migration is complete, with lifecycle aliases for
   renamed args and `decisions.Rmd` updated to match.
2. **Package identity.** DESCRIPTION rebranded as a general lm-visualization
   package (no more "Math425 at BYUI"); James Beeson added to `Authors@R` as
   maintainer (`cre`); canonical GitHub remote is `saundersg/Applr`.
3. **Deprecated stubs in 1.0.** `geom_fit` (error stub) and `drawit`
   (deprecation shim forwarding to `slice_2d()`) both ship in 1.0 and are
   removed at 2.0.

## Phase 1 — API settlement (main session + James)

- [x] Apply renames — `xaxis` → `x_axis` landed 2026-07-12 (commit b78365f)
      with aliases for the old spelling.
- [x] `drawit` deprecation — shim in `R/deprecated.R` warns and forwards to `slice_2d()`.
- [x] Update `decisions.Rmd` naming standard to the settled convention (2026-07-12).

## Phase 2 — Documentation (prompts A/B/C ran 2026-07-12 and are deleted; reviewed & verified same day)

Rule for every exported function: `@return`, `@description` that says what it
does and when to reach for it, and `@examples` that show the **range** of the
function (not one minimal call). Examples must run unattended in seconds;
wrap plotly/interactive ones in `if (interactive())`.

- [x] **Prompt A** — utility docs pass: `theme_lc`, `lm_equation`/`lm_latex`,
      `scatter_3d`, `diagnose`, `get_inverse_function` (internal → `@noRd`).
      Review note: two "Use it when…" paragraphs in `lm_equation.R` sat after
      `@param clearer` (would merge into that param's doc) — fixed on review.
      Session also surfaced three real `scatter_3d` bugs, now tracked in
      `dev_todo.Rmd` (I() terms, ineffective `colors`, eval(parse) fragility).
- [x] **Prompt B** — README refresh: full rewrite verified against current
      API (autoplot, intervals, bands, slice-text helpers, issues link;
      drawit removed).
- [x] **Prompt C** — flagship docs: `geom_slice` + caption/subtitle/text +
      `autoplot.lm`; examples cover predict_vars (single/multi), intervals,
      band, grouping, faceting, back_transform, n; `@seealso` cross-links.
      Representative examples smoke-tested successfully on review.
- [ ] Vignette: "Getting started with Applr" — one dataset, `lm()` →
      `autoplot()` → `geom_slice()` with slices/intervals/captions.
- [x] `NEWS.md` started at 1.0.0.

## Phase 3 — Packaging mechanics (main session, mostly done 2026-07-12)

- [x] Fix `.Rbuildignore` (was excluding `ALR.Rproj` — stale name — and
      missing `testing/`, `for_devs/`, `scripts/`, `CLAUDE.md`, etc.)
- [x] Delete stray `Rplots.pdf`; gitignore it.
- [x] Add `URL:`/`BugReports:` to DESCRIPTION.
- [ ] Narrow blanket `@import` tags to `@importFrom` across `R/` (avoids
      namespace collisions and check NOTEs). Coordinate: touches many files,
      do after the docs prompts land.
- [ ] `devtools::document()` (James) — regenerate NAMESPACE/man after all of
      the above; confirm `geom_fit`/`drawit`/`get_inverse_function` Rd pages
      match their final status.

## Phase 4 — Verification & release

- [ ] `devtools::check()` clean (0 errors, 0 warnings, notes triaged).
- [ ] Full test suite green: `Rscript testing/run.R` + visual pass via
      `testing/report.Rmd`.
- [ ] Spell check (`devtools::spell_check()`), URL check.
- [ ] Bump Version to `1.0.0` in DESCRIPTION (deliberately left at 0.0.0.9000
      until check is clean), finalize NEWS.md, tag `v1.0.0` on GitHub.

## Post-1.0 (explicitly deferred)

- `data`/aesthetic args and `full_range` for `geom_slice`; intervals in
  legend; `slice_2d` interval; plotly `autoplot(sliders=TRUE)`; gif
  animation; scatter_3d test story; pkgdown site + R CMD check GitHub Action
  (both cheap and high-value — good first post-release tasks, or do them
  pre-release if time allows).
