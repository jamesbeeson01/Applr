# Deprecated: use slice_2d() instead

`drawit()` drew a single base-R slice of an
[`lm()`](https://rdrr.io/r/stats/lm.html) and required the caller to
name a value for every other predictor. That job is now done by
[`slice_2d()`](https://saundersg.github.io/Applr/reference/slice_2d.md),
which imputes unspecified predictors (mean for numeric, most common
level for factors) instead of demanding them. `drawit()` is kept as a
deprecated shim: it warns and forwards to
[`slice_2d()`](https://saundersg.github.io/Applr/reference/slice_2d.md),
mapping `xaxis` to `x_axis` and passing graphical parameters (`col`,
`lty`, ...) straight through. It will be removed in a future release.

## Usage

``` r
drawit(model, xaxis, ...)
```

## Arguments

- model:

  A linear model fit with
  [`stats::lm()`](https://rdrr.io/r/stats/lm.html).

- xaxis:

  The primary explanatory variable to vary along the x-axis.

- ...:

  Graphical parameters forwarded to
  [`slice_2d()`](https://saundersg.github.io/Applr/reference/slice_2d.md)
  (e.g. `col`, `lty`).

## Value

A 2D base-R plot of a model slice (called for its side effect).

## See also

[`slice_2d()`](https://saundersg.github.io/Applr/reference/slice_2d.md)
