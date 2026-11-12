# CASE: cond_scatter_3d
# scatter_3d()'s refusals, and that a good model builds with no plotly
# warnings.

covers("scatter_3d.shape-errors", "scatter_3d.predict-fails", "scatter_3d.no-build-warnings",
       "shared.validation.function-name")

built <- function(...) function() plotly::plotly_build(scatter_3d(...))

raises("one_predictor", built(lm(mpg ~ wt, mtcars)), "error", "needs exactly two predictor variables")
raises("three_predictors", built(lm(mpg ~ wt + hp + qsec, mtcars)), "error", "the model has 3")
raises("two_response_variables", built(lm(I(mpg + hp) ~ wt + qsec, mtcars)), "error",
       "needs a single response variable")
raises("factor_predictor", built(lm(Sepal.Length ~ Sepal.Width + Species, iris)), "error",
       'but `Species` is a "factor"')
raises("factor_in_formula", built(lm(mpg ~ wt + factor(cyl), mtcars)), "error",
       "could not evaluate the model across `wt` and `cyl`")
raises("not_a_model", built(NULL), "error", "needs a fitted model")
raises("builds_quietly", built(lm(mpg ~ wt + hp, mtcars), n = 10), character())
