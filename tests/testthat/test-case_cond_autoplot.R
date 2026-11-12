# CASE: cond_autoplot
# autoplot()'s refusals and the choices it announces.

mpg <- ggplot2::mpg
quiet_summary <- function(...) function() autoplot(..., summary = FALSE)

covers("autoplot.input-errors", "autoplot.x-first-numeric", "autoplot.categorical-to-colour-facet")

raises("mapping_not_aes", quiet_summary(lm(mpg ~ wt, mtcars), mapping = list(x = "wt")), "error",
       "`mapping` must be created by aes().")
raises("no_data_argument", function() {
  y <- mtcars$mpg
  x <- mtcars$wt
  autoplot(lm(y ~ x), summary = FALSE)
}, "error", "fitted without a `data` argument")
raises("two_response_variables", quiet_summary(lm(I(mpg / hp) ~ wt, mtcars)), "error",
       "does not use exactly one variable")
raises("no_predictors", quiet_summary(lm(mpg ~ 1, mtcars)), "error", "The model has no predictors")
raises("no_numeric_predictor", quiet_summary(lm(hwy ~ drv + fl, mpg)), "error",
       "None of the model's predictors are numeric")
raises("announces_choices", quiet_summary(lm(hwy ~ drv + displ + cyl + year, mpg)),
       c("message", "message", "message", "message"),
       c("The first predictor `drv` is not numeric - used `displ`", "Coloured the plot by `drv`",
         "Faceted the plot by `cyl`", "Value for `year` not specified"))
