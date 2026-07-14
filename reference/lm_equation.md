# Write out the equation of a linear model

Takes a fitted linear model and returns a human-readable equation string
showing the relationship between the response variable and predictors.
Coefficients are rounded to 3 significant figures for readability. Terms
are named as in the fitted coefficients, so factor predictors show one
term per dummy level (e.g. `2.1*gB`) and models without an intercept
print no intercept.

## Usage

``` r
lm_equation(model, clearer = FALSE)
```

## Arguments

- model:

  A linear model

- clearer:

  If `TRUE`, factor terms are displayed with the factor name and level
  spelled out (e.g. `4.09*(g="B")` instead of `4.09*gB`).

## Value

A character string of length 1 containing the fitted equation, e.g.
`"mpg = 30.7 - 0.0248*disp - 0.0245*hp"`.

## Details

Use it when you want to report or sanity-check a fitted model as an
equation rather than a coefficient table — for example when writing up
homework or checking which dummy terms a factor produced.

## Examples

``` r
# Simple regression
lm_equation(lm(mpg ~ wt, data = mtcars))
#> [1] "mpg = 37.3 - 5.34*wt"

# Multiple predictors
lm_equation(lm(mpg ~ disp + hp, data = mtcars))
#> [1] "mpg = 30.7 - 0.0303*disp - 0.0248*hp"

# Factor predictor: one term per non-reference level
model <- lm(Sepal.Length ~ Sepal.Width + Species, data = iris)
lm_equation(model)
#> [1] "Sepal.Length = 2.25 + 0.804*Sepal.Width + 1.46*Speciesversicolor + 1.95*Speciesvirginica"

# `clearer = TRUE` spells out factor levels
lm_equation(model, clearer = TRUE)
#> [1] "Sepal.Length = 2.25 + 0.804*Sepal.Width + 1.46*(Species=\"versicolor\") + 1.95*(Species=\"virginica\")"

# Transformed terms and interactions
lm_equation(lm(mpg ~ wt + I(wt^2), data = mtcars))
#> [1] "mpg = 49.9 - 13.4*wt + 1.17*I(wt^2)"
lm_equation(lm(Sepal.Length ~ Sepal.Width * Species, data = iris))
#> [1] "Sepal.Length = 2.64 + 0.69*Sepal.Width + 0.901*Speciesversicolor + 1.27*Speciesvirginica + 0.175*Sepal.Width:Speciesversicolor + 0.211*Sepal.Width:Speciesvirginica"

# No-intercept models print no intercept
lm_equation(lm(mpg ~ 0 + wt, data = mtcars))
#> [1] "mpg = 5.29*wt"
```
