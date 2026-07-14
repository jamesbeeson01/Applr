# Plot a 3D-graphable linear model

Creates an interactive 3D visualization of a linear model with exactly
two predictor variables. The model's own data is drawn as scattered
points and a semi-transparent regression surface is overlaid across the
whole predictor space, so you can *see* the fitted surface rather than
read its coefficients.

## Usage

``` r
scatter_3d(model, n = 100, colors = c("blue", "yellow"))
```

## Arguments

- model:

  A fitted [`lm()`](https://rdrr.io/r/stats/lm.html) with exactly two
  numeric predictor variables.

- n:

  Number of grid points along each predictor axis used to evaluate the
  prediction surface (default 100); larger values give a smoother
  surface at the cost of speed.

- colors:

  Character vector defining the marker color gradient, mapped to the
  response value so points read from low to high.

## Value

A plotly object (an interactive 3D plot). When printed — e.g. at the
console or in RStudio — it renders in the Viewer pane.

## Details

Reach for it when a model has exactly two predictors and you want to
understand how it behaves across their combinations. Transformed terms
are fine — the surface is evaluated with
[`predict()`](https://rdrr.io/r/stats/predict.html) on the raw
predictors, so `lm(z ~ x + I(x^2) + y)` graphs over `x` and `y` as
expected.

## Examples

``` r
if (interactive()) {
  # A flat regression plane over two predictors
  model <- lm(mpg ~ disp + hp, data = mtcars)
  scatter_3d(model)

  # Custom marker gradient and a finer surface grid
  scatter_3d(model, n = 200, colors = c("blue", "yellow"))

  # Transformed terms graph over their raw predictors
  curved <- lm(mpg ~ wt + I(wt^2) + hp, data = mtcars)
  scatter_3d(curved)

  # Interaction models produce a twisted (non-planar) surface
  twisted <- lm(Sepal.Length ~ Sepal.Width * Petal.Length, data = iris)
  scatter_3d(twisted)
}
```
