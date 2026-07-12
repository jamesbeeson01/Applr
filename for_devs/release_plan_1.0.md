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

## Phase 0 — Decisions (James; blocks Phase 1)

These are tracked as ULTRA-priority items in `dev_todo.Rmd`:

1. **Final public names.** Are `slice_2d`, `geom_slice`, and `xaxis` the
   names we ship? Decide the snake_case migration (`xaxis` → `x_axis`,
   `color`/`colors`) now. Whatever is decided, `decisions.Rmd` naming
   standards get updated to match, and renamed args get lifecycle aliases.
2. **Package identity.** DESCRIPTION Title/Description still say
   "Math425 at BYUI." Rebrand as a general lm-visualization package, or keep
   the course framing? Also: add James Beeson to `Authors@R` (role?), confirm
   the canonical GitHub remote (README says `saundersg/Applr`).
3. **Fate of deprecated stubs in 1.0.** `geom_fit` (error stub) and `drawit`
   (being deprecated now): recommend both ship in 1.0 as warning/error stubs,
   removed at 2.0. Confirm.

## Phase 1 — API settlement (main session + James)

- [ ] Apply whatever renames Phase 0 decides, with deprecation aliases
      (consider the {lifecycle} package for consistent warnings).
- [ ] `drawit` deprecation (James, in progress).
- [ ] Update `decisions.Rmd` naming standard to the settled convention.

## Phase 2 — Documentation (parallelizable; prompts in `for_devs/parallel_prompts/`)

Rule for every exported function: `@return`, `@description` that says what it
does and when to reach for it, and `@examples` that show the **range** of the
function (not one minimal call). Examples must run unattended in seconds;
wrap plotly/interactive ones in `if (interactive())`.

- [ ] **Prompt A** — utility docs pass: `theme_lc`, `lm_equation`/`lm_latex`,
      `scatter_3d`, `diagnose`, `get_inverse_function` (internal → `@noRd`).
- [ ] **Prompt B** — README refresh: fix stale `geom_slice` examples, remove
      `drawit` section, add repo links.
- [ ] **Prompt C** — flagship docs: `geom_slice` + `geom_slice_caption` /
      `_subtitle` / `_text` + `autoplot.lm`, mining `testing/cases/gs_*` for
      example material (predict_vars, intervals, grouping, faceting,
      back-transform).
- [ ] Vignette: "Getting started with Applr" — one dataset, `lm()` →
      `autoplot()` → `geom_slice()` with slices/intervals/captions.
      (After Phase 1 so examples use final names.)
- [ ] `NEWS.md` started at 1.0.0.

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
