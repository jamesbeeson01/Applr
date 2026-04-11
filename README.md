# Applr

A small R package for visualizing linear models—especially high-dimensional ones—with ease.

## Installation

``` r
install.packages("devtools")      # if you don’t have it
devtools::install_github("saundersg/Applr")
library(Applr)
```

## Quick start

``` r
# Basic model
model <- lm(log(mpg) ~ disp, data = mtcars)

# Base R: plot fitted model
slice_2d(model)

# ggplot: plot fitted model
library(ggplot2)
ggplot(mtcars, aes(disp, mpg)) +
  geom_point() +
  geom_slice(model)

# High dimensional model
model <- lm(log(mpg) ~ disp + cyl + I(hp^2), data = mtcars)

# Base R: add multiple 2-D slices
slice_2d(model)
add_slice_2d(model, hp = min(mtcars$hp))
add_slice_2d(model, hp = max(mtcars$hp))

# ggplot2: add a model slice as a layer
library(ggplot2)
ggplot(mtcars, aes(disp, mpg)) +
  geom_point() +
  facet_wrap(~cyl) +
  geom_slice(model = model,
             predict_vars = list(hp = 110))
```

------------------------------------------------------------------------

## Function reference and examples

All exported functions found in the `R/` folder are listed below with a short description and a runnable example that uses built-in datasets.

### 1) `slice_2d()`

Create a new base-R plot that shows a 2-D slice of a high-dimensional linear model.\
Unspecified xaxis defaults to first variable in model. Unspecified values are held at sensible defaults (numeric → mean, factor → first level).

``` r
model <- lm(mpg ~ disp + hp, data = mtcars)
slice_2d(model)
#--or--
slice_2d(model, xaxis = "hp", disp = 250, n = 150, col = "blue", lwd = 2)
```

### 2) `add_slice_2d()`

Add a 2-D slice line to an *existing* base-R plot. X and Y axis names must match the plot it is being added to.

``` r
model <- lm(mpg ~ disp + hp, data = mtcars)
plot(mpg ~ disp, data = mtcars)
add_slice_2d(model)
#--or--
plot(mpg ~ hp, data = mtcars)
add_slice_2d(model, xaxis = "hp", hp = 110, col = "red", lty = 2)
```

This example does not work because the Y axes do not match (y and 1/y)

``` r
model <- lm(1/mpg ~ disp + hp, data = mtcars)
plot(mpg ~ disp, data = mtcars)
add_slice_2d(model) # will not plot
```

### 3) `drawit()`

Draw a slice curve for a model in base-R graphics.\
For multi-variable models you should supply values for all other predictors.

``` r
model <- lm(mpg ~ wt + am + qsec, data = mtcars)
plot(mpg ~ wt, data = mtcars)
drawit(model = model, xaxis = "wt", am = 1, qsec = 17,
       col = "steelblue", lty = 1)
```

### 4) `geom_slice()`

A convenient **ggplot2** layer that draws a model slice across your plot (and its facets).\
Use `predict_vars` to set values for predictors not on the x-axis or in facets.

``` r
library(ggplot2)
model <- lm(mpg ~ disp + hp + cyl, data = mtcars)

ggplot(mtcars, aes(disp, mpg)) +
  geom_point() +
  facet_wrap(~cyl) +
  geom_slice(model = model, predict_vars = list(hp = 110),
             color = "steelblue", linewidth = 1)
```

### 5) `scatter_3d()`

Create an interactive 3-D scatter plot with a fitted regression surface\
(models must have exactly two predictors).

``` r
model <- lm(mpg ~ disp + hp, data = mtcars)
scatter_3d(model, colors = c("blue", "yellow"))
```

### 6) `lm_equation()`

Return a plain-text equation for a fitted linear model.

``` r
model <- lm(mpg ~ disp + hp, data = mtcars)
lm_equation(model)
```

### 7) `lm_latex()`

Print a LaTeX-formatted equation for a fitted linear model\
(ideal for LaTeX or R Markdown documents).

``` r
model <- lm(mpg ~ disp + hp, data = mtcars)
lm_latex(model)
```

### 8) `theme_lc()`

A custom **ggplot2** theme plus default aesthetic tweaks.

``` r
library(ggplot2)
ggplot(mtcars, aes(wt, mpg)) +
  geom_point() +
  theme_lc()
```

### 9) Advanced: `StatSlice` and `GeomSlice`

Low-level **ggproto** objects that power `geom_slice()`.\
Most users never need to call these directly, but you can for custom layers.

``` r
library(ggplot2)
model <- lm(mpg ~ disp + hp + cyl, data = mtcars)

ggplot(mtcars, aes(disp, mpg)) +
  geom_point() +
  layer(stat = StatSlice,
        geom = GeomSlice,
        position = "identity",
        inherit.aes = TRUE,
        params = list(model = model, predict_vars = list(hp = 110)))
```

------------------------------------------------------------------------

## Tips

• For multi-variable models, specify values for predictors (e.g., `hp = 110`) to choose the slice you want.\
• Factors included in `facet_wrap()` or `facet_grid()` should also appear in the model you pass to `geom_slice()`.\
• New to R modeling? `lm(y ~ x1 + x2, data = df)` fits a linear model of `y` on `x1` and `x2`.

## Getting help

• Use R’s built-in help: `Applr`, `?slice_2d`, `?geom_slice`, `?scatter_3d`, etc. • Open issues or suggest improvements on the project’s GitHub repository.

Enjoy clearer model visualizations with **Applr**!

## Attributions

We thank Cameron McClellan and James Beeson for their work on the package, and of course Garrett Saunders for being a remarkable teacher and inspiration to do great things with statistics!
