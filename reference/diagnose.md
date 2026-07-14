# Diagnostic plots for linear models

Generates a set of three diagnostic plots for a linear model object,
side by side: Residuals vs Fitted (checks linearity and constant
variance), Normal Q-Q (checks normality of residuals), and residuals in
data order (checks independence). Use it right after fitting a model to
check the regression assumptions in one call instead of building each
plot yourself. Graphical parameters (`mfrow`) are restored on exit.

## Usage

``` r
diagnose(model)
```

## Arguments

- model:

  An object of class `lm`.

## Value

None. The function is called for its side effect of producing plots.

## Examples

``` r
# Simple regression
diagnose(lm(mpg ~ wt, data = mtcars))


# Works the same for multiple regression
diagnose(lm(mpg ~ wt + hp + disp, data = mtcars))


# A poorly-specified model shows curvature in Residuals vs Fitted
diagnose(lm(dist ~ speed, data = cars))
```
