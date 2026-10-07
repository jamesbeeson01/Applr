# Write out the equation of a linear model in LaTeX format

Takes a fitted linear model and generates a properly formatted LaTeX
equation suitable for inclusion in R Markdown documents, academic
papers, or presentations. The output includes underbrace notation to
clearly label predicted values and predictor variables, making it ideal
for educational or presentation purposes. Coefficients are rounded to 3
significant figures.

## Usage

``` r
lm_latex(model, style = c("prettier", "brackets", "raw"))
```

## Arguments

- model:

  A linear model

- style:

  How factor terms are labelled. `"prettier"` (the default) spells out
  the factor name and level (e.g. `(Species="setosa")`), `"brackets"`
  shows the level alone (e.g. `[setosa]`), and `"raw"` keeps the
  design-matrix names (e.g. `Speciessetosa`).

## Value

A character string of length 1 containing the display-math LaTeX
equation (wrapped in `$$...$$`), printed to the console with
[`cat()`](https://rdrr.io/r/base/cat.html) and returned invisibly.

## Details

Use it when a model needs to appear as typeset math — in an R Markdown
chunk with `results = "asis"`, the LaTeX string prints ready to render.

## Examples

``` r
# Simple regression
lm_latex(lm(mpg ~ wt, data = mtcars))
#> $$\underbrace{\hat{Y_i}}_{\text{Pred. mpg}} = 37.3 - 5.34\underbrace{X_{1i}}_{\text{wt}}$$

# Multiple predictors and a transformed term
lm_latex(lm(mpg ~ disp + hp + I(hp^2), data = mtcars))
#> $$\underbrace{\hat{Y_i}}_{\text{Pred. mpg}} = 37.4 - 0.0189\underbrace{X_{1i}}_{\text{disp}} - 0.138\underbrace{X_{2i}}_{\text{hp}} + 0.00028\underbrace{X_{3i}}_{\text{I(hp^2)}}$$

# Factor predictor with interactions, spelled out by default
model <- lm(Sepal.Length ~ Sepal.Width * Species, data = iris)
lm_latex(model)
#> $$\underbrace{\hat{Y_i}}_{\text{Pred. Sepal.Length}} = 2.64 + 0.69\underbrace{X_{1i}}_{\text{Sepal.Width}} + 0.901\underbrace{X_{2i}}_{\text{(Species="versicolor")}} + 1.27\underbrace{X_{3i}}_{\text{(Species="virginica")}} + 0.175\underbrace{X_{4i}}_{\text{Sepal.Width:(Species="versicolor")}} + 0.211\underbrace{X_{5i}}_{\text{Sepal.Width:(Species="virginica")}}$$

# `style = "brackets"` shows just the level; `"raw"` keeps design-matrix names
lm_latex(model, style = "brackets")
#> $$\underbrace{\hat{Y_i}}_{\text{Pred. Sepal.Length}} = 2.64 + 0.69\underbrace{X_{1i}}_{\text{Sepal.Width}} + 0.901\underbrace{X_{2i}}_{\text{[versicolor]}} + 1.27\underbrace{X_{3i}}_{\text{[virginica]}} + 0.175\underbrace{X_{4i}}_{\text{Sepal.Width:[versicolor]}} + 0.211\underbrace{X_{5i}}_{\text{Sepal.Width:[virginica]}}$$
lm_latex(model, style = "raw")
#> $$\underbrace{\hat{Y_i}}_{\text{Pred. Sepal.Length}} = 2.64 + 0.69\underbrace{X_{1i}}_{\text{Sepal.Width}} + 0.901\underbrace{X_{2i}}_{\text{Speciesversicolor}} + 1.27\underbrace{X_{3i}}_{\text{Speciesvirginica}} + 0.175\underbrace{X_{4i}}_{\text{Sepal.Width:Speciesversicolor}} + 0.211\underbrace{X_{5i}}_{\text{Sepal.Width:Speciesvirginica}}$$

# Capture the string instead of just printing it
eq <- lm_latex(lm(mpg ~ wt, data = mtcars))
#> $$\underbrace{\hat{Y_i}}_{\text{Pred. mpg}} = 37.3 - 5.34\underbrace{X_{1i}}_{\text{wt}}$$
nchar(eq)
#> [1] 90
```
