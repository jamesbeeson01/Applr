# Automatically plot a linear model

[`autoplot()`](https://ggplot2.tidyverse.org/reference/autoplot.html)
turns a fitted [`lm()`](https://rdrr.io/r/stats/lm.html) into a complete
ggplot in one call: the data the model was fitted to as a scatter, with
a
[`geom_slice()`](https://saundersg.github.io/Applr/reference/geom_slice.md)
prediction line through it. The result is a regular ggplot, so it can be
extended with `+` as usual (labels, scales, more layers).

## Usage

``` r
# S3 method for class 'lm'
autoplot(
  object,
  ...,
  data = NULL,
  mapping = NULL,
  type = c("2d", "3d"),
  x_axis = NULL,
  xaxis = NULL
)
```

## Arguments

- object:

  A linear model fitted by [`lm()`](https://rdrr.io/r/stats/lm.html)
  **with a `data` argument** — the data is recovered from the model, so
  `lm(y ~ x, data = your_data)` works but
  `lm(your_data$y ~ your_data$x)` does not.

- ...:

  Passed on to
  [`geom_slice()`](https://saundersg.github.io/Applr/reference/geom_slice.md)
  — for example `predict_vars = list(hp = 110)` to choose the slice,
  `interval = "confidence"` for a ribbon, or fixed aesthetics such as
  `color = "red"` — or to
  [`scatter_3d()`](https://saundersg.github.io/Applr/reference/scatter_3d.md)
  when `type = "3d"`.

- data:

  A data frame to draw the scatter from instead of the data recovered
  from the model — for example the model's data with extra columns added
  for `mapping` aesthetics. Passed to
  [`ggplot2::ggplot()`](https://ggplot2.tidyverse.org/reference/ggplot.html).
  The rows must still match the data the model was fitted to
  ([`geom_slice()`](https://saundersg.github.io/Applr/reference/geom_slice.md)
  checks, and errors on a mismatch).

- mapping:

  Extra aesthetics created with
  [`ggplot2::aes()`](https://ggplot2.tidyverse.org/reference/aes.html),
  passed to
  [`ggplot2::ggplot()`](https://ggplot2.tidyverse.org/reference/ggplot.html)
  — for example `mapping = aes(color = factor(cyl))`. Entries named `x`
  or `y` override the automatically chosen axes.

- type:

  `"2d"` (default) for a
  [`geom_slice()`](https://saundersg.github.io/Applr/reference/geom_slice.md)
  ggplot, or `"3d"` for an interactive
  [`scatter_3d()`](https://saundersg.github.io/Applr/reference/scatter_3d.md)
  surface (needs exactly two numeric predictors).

- x_axis:

  The name of the predictor to place on the x-axis, such as
  `x_axis = "disp"`. Defaults to the model's first numeric predictor.
  Ignored when `type = "3d"`.

- xaxis:

  Deprecated; use `x_axis` instead.

## Value

A ggplot of the model's data with a slice of the model drawn through it,
or — when `type = "3d"` — a plotly surface from
[`scatter_3d()`](https://saundersg.github.io/Applr/reference/scatter_3d.md).

## Details

Pass `type = "3d"` for a model with exactly two numeric predictors to
get an interactive
[`scatter_3d()`](https://saundersg.github.io/Applr/reference/scatter_3d.md)
surface instead of the 2-D slice; `...` is then forwarded to
[`scatter_3d()`](https://saundersg.github.io/Applr/reference/scatter_3d.md)
(e.g. `n`, `colors`).

The model's *first numeric* predictor goes on the x-axis (override with
`x_axis`) and the raw response variable goes on the y-axis. Everything
else is handled by
[`geom_slice()`](https://saundersg.github.io/Applr/reference/geom_slice.md)
and reported on the console: predictors not visible on the plot are
imputed (mean for numeric, most common value for factor/character), and
a transformed response such as `lm(log(y) ~ x)` is automatically
back-transformed to match the raw y-axis.

## See also

[`geom_slice()`](https://saundersg.github.io/Applr/reference/geom_slice.md),
which draws the line and handles everything slice-shaped;
[`scatter_3d()`](https://saundersg.github.io/Applr/reference/scatter_3d.md)
for the interactive surface; and
[`geom_slice_subtitle()`](https://saundersg.github.io/Applr/reference/geom_slice_subtitle.md)
/
[`geom_slice_text()`](https://saundersg.github.io/Applr/reference/geom_slice_text.md)
to annotate the result.

## Examples

``` r
library(ggplot2)

# A complete plot from a model in one call
autoplot(lm(mpg ~ disp, data = mtcars))


# Predictors not on the plot are imputed (a message says how)
autoplot(lm(mpg ~ disp + hp, data = mtcars))
#> Value for `hp` not specified - Used mean: 146.7
#>     To choose a slice, use 'predict_vars = list(hp = 146.7)'.


# Choose which predictor goes on the x-axis
autoplot(lm(mpg ~ disp + hp, data = mtcars), x_axis = "hp")
#> Value for `disp` not specified - Used mean: 230.7
#>     To choose a slice, use 'predict_vars = list(disp = 230.7)'.


# Transformed response, back-transformed onto the raw mpg axis
autoplot(lm(log(mpg) ~ disp, data = mtcars))
#> Predictions of `log(mpg)` were back-transformed to match the `mpg` axis.
#>     To turn this off, use 'back_transform = FALSE'.


# Options pass through to geom_slice(); the result is a normal ggplot
autoplot(lm(mpg ~ disp + hp, data = mtcars),
         predict_vars = list(hp = 110), interval = "confidence") +
  labs(title = "Slice at hp = 110")


# Custom data and extra aesthetics for the scatter
autoplot(lm(mpg ~ disp, data = mtcars),
         data = mtcars, mapping = aes(color = factor(cyl)))


# An interactive 3-D surface for a two-predictor model
if (interactive()) {
  autoplot(lm(mpg ~ disp + hp, data = mtcars), type = "3d")
}
```
