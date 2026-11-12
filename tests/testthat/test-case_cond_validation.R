# CASE: cond_validation
# Arguments checked before any plot is built: the model, n, interval,
# back_transform, full_range, a stray aes(), predict_vars and band. Each
# call's conditions are judged as wording.

model <- lm(mpg ~ wt + hp, data = mtcars)
cars <- mtcars
on_plot <- function(...) function() ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) + geom_slice(...)

covers("shared.validation.model", "shared.validation.dollar-names", "shared.validation.n",
       "shared.validation.interval", "shared.validation.back-transform-arg",
       "geom_slice.stray-aes", "geom_slice.full-range-twice", "shared.held-values.malformed",
       "shared.held-values.bad-level", "shared.band.with-interval", "geom_slice.model-name",
       "shared.conditions.two-part-format", "shared.conditions.severity")

raises("no_model", function() geom_slice(), "error", "geom_slice() needs a fitted model.")
raises("not_lm", function() geom_slice(data.frame(x = 1)), "error", 'received a "data.frame"')
raises("dollar_names", function() geom_slice(lm(cars$mpg ~ cars$wt)), "error", "`cars$mpg`")
raises("n_too_small", function() geom_slice(model, n = 1), "error", "`n` must be")
raises("interval_unknown", function() geom_slice(model, interval = "ci"), "error", "`interval` must be one of")
raises("back_transform_name", function() geom_slice(model, back_transform = "ln"), "error", '"ln" is not a known')
raises("back_transform_arity", function() geom_slice(model, back_transform = function(a, b) a), "error",
       "exactly one argument")
raises("back_transform_class", function() geom_slice(model, back_transform = 2), "error", 'received a "numeric"')
raises("stray_aes", function() geom_slice(model, ggplot2::aes(wt, mpg)), "error",
       "does not take an aesthetic mapping")
raises("full_range_twice", function() geom_slice(model, full_range = TRUE, fullrange = TRUE), "error",
       "same argument")
raises("full_range_not_logical", function() geom_slice(model, full_range = "yes"), "error",
       "`full_range` must be TRUE or FALSE.")
raises("predict_vars_unnamed", function() geom_slice(model, predict_vars = list(100)), "error",
       "named list")
raises("predict_vars_response", function() geom_slice(model, predict_vars = list(mpg = 20)), "error",
       "`mpg` is the model's response")
raises("predict_vars_unknown", function() geom_slice(model, predict_vars = list(cyl = 4)), "error",
       '"cyl" not found in the model')
raises("predict_vars_empty", function() geom_slice(model, predict_vars = list(hp = NULL, wt = list(1))), "error",
       "must be one or more values")
raises("predict_vars_bad_level", function() {
  ggplot2::ggplot(iris, ggplot2::aes(Petal.Length, Sepal.Length)) +
    geom_slice(lm(Sepal.Length ~ Petal.Length + Species, iris), predict_vars = list(Species = "rose"))
}, "error", '"rose" is not a level')
# A character predictor isn't a factor, so the unknown value only fails in
# predict(); ggplot2 turns that into a warning and draws the plot without
# the line.
raises("predict_vars_unknown_character", function() {
  ggplot2::ggplot(ggplot2::mpg, ggplot2::aes(displ, hwy)) +
    geom_slice(lm(hwy ~ displ + drv, ggplot2::mpg), predict_vars = list(drv = "x"))
}, "warning", "predict() failed for this slice", format = FALSE)
raises("predict_vars_not_number", on_plot(model, predict_vars = list(hp = "fast")), "error",
       '"fast" for the numeric variable `hp`')
raises("band_wrong_type", function() geom_slice(model, band = 3), "error", "`band` must be TRUE, FALSE")
raises("band_with_interval", function() geom_slice(model, band = TRUE, interval = "confidence"), "error",
       "cannot be combined")
