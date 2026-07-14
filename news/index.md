# Changelog

## Applr 1.0.0 (unreleased)

First stable release. The public API documented here is covered by a
stability promise: renames or removals after 1.0 go through a
deprecation cycle.

### New features

- [`geom_slice()`](https://saundersg.github.io/Applr/reference/geom_slice.md)
  — full rewrite as a proper ggplot2 `Layer` subclass. Draws slices of a
  fitted `lm` across the plot and its facets, with grouping, faceting,
  automatic back-transformation of transformed responses, multi-value
  `predict_vars` (values crossed into multiple lines), and
  `interval = "confidence"` / `"prediction"` bands.
- [`geom_slice_caption()`](https://saundersg.github.io/Applr/reference/geom_slice_caption.md),
  [`geom_slice_subtitle()`](https://saundersg.github.io/Applr/reference/geom_slice_subtitle.md),
  [`geom_slice_text()`](https://saundersg.github.io/Applr/reference/geom_slice_text.md)
  — annotation helpers that report the model, held values, and line
  labels.
- [`autoplot()`](https://ggplot2.tidyverse.org/reference/autoplot.html)
  method for `lm` objects — scatter +
  [`geom_slice()`](https://saundersg.github.io/Applr/reference/geom_slice.md) +
  [`theme_lc()`](https://saundersg.github.io/Applr/reference/theme_lc.md)
  in one call.
- [`lm_equation()`](https://saundersg.github.io/Applr/reference/lm_equation.md)
  /
  [`lm_latex()`](https://saundersg.github.io/Applr/reference/lm_latex.md)
  — plain-text and LaTeX model equations, with clearer factor
  formatting.

### Deprecations

- [`geom_fit()`](https://saundersg.github.io/Applr/reference/geom_fit.md)
  — removed; calling it errors with guidance to
  [`geom_slice()`](https://saundersg.github.io/Applr/reference/geom_slice.md).
- [`drawit()`](https://saundersg.github.io/Applr/reference/drawit.md) —
  deprecated in favor of
  [`slice_2d()`](https://saundersg.github.io/Applr/reference/slice_2d.md)
  /
  [`add_slice_2d()`](https://saundersg.github.io/Applr/reference/add_slice_2d.md).
