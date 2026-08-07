# Applr 1.0.0 (unreleased)

First stable release. The public API documented here is covered by a
stability promise: renames or removals after 1.0 go through a deprecation
cycle.

## New features

* `geom_slice()` — full rewrite as a proper ggplot2 `Layer` subclass. Draws
  slices of a fitted `lm` across the plot and its facets, with grouping,
  faceting, automatic back-transformation of transformed responses,
  multi-value `predict_vars` (values crossed into multiple lines), and
  `interval = "confidence"` / `"prediction"` bands.
* `geom_slice_caption()`, `geom_slice_subtitle()`, `geom_slice_text()` —
  annotation helpers that report the model, held values, and line labels.
* `autoplot()` method for `lm` objects — scatter + `geom_slice(..., interval = "confidence")` +
  `geom_slice_subtitle()` in one call, with model summary printed to console
  for easy exploration and iteration.
* `lm_equation()` / `lm_latex()` — plain-text and LaTeX model equations,
  with clearer factor formatting.

## Deprecations

* `geom_fit()` — removed; calling it errors with guidance to `geom_slice()`.
* `drawit()` — deprecated in favor of `slice_2d()` / `add_slice_2d()`.
