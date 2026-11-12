# CASE: cond_build
# Conditions geom_slice() raises once the plot is added or built: the plot's
# data and axes, groupings that can't pin, and values the plot can't use.

mpg <- ggplot2::mpg
model <- lm(mpg ~ wt + hp, data = mtcars)
on_mtcars <- function(mapping, ...) function() ggplot2::ggplot(mtcars, mapping) + geom_slice(...)

covers("shared.model-data.plot-data-mismatch", "shared.model-data.no-data-arg",
       "shared.model-data.fitted-in-function", "geom_slice.unmapped-axis",
       "geom_slice.discrete-axis", "geom_slice.x-uses-no-predictor", "shared.slicing.bare-group",
       "shared.slicing.continuous-colour", "shared.held-values.on-x-axis",
       "shared.imputation.unsupported-class", "ggproto_objects.raw-layer-no-mapping")

raises("plot_data_mismatch", function() {
  ggplot2::ggplot(mtcars[1:20, ], ggplot2::aes(wt, mpg)) + geom_slice(model)
}, "error", "The data on the plot is not the data `model` was fitted to.")
raises("plot_data_reordered", function() {
  ggplot2::ggplot(mtcars[32:1, ], ggplot2::aes(wt, mpg)) + geom_slice(model, predict_vars = list(hp = 100))
}, character())
raises("model_data_gone", function() {
  fit <- function() { d <- mtcars; m <- lm(mpg ~ wt, data = d); rm(d); m }
  ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) + geom_slice(fit())
}, "error", "The data the model was fitted on could not be found.")
# Fitted without `data`, the model's variables are found in the formula's
# environment, so the slice is drawn with nothing to say.
raises("no_data_argument_recovered", function() {
  wt <- mtcars$wt
  mpg <- mtcars$mpg
  ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) + geom_slice(lm(mpg ~ wt))
}, character())
raises("axis_unmapped", function() ggplot2::ggplot(mtcars, ggplot2::aes(wt)) + geom_slice(model),
       "error", "needs both `x` and `y` mapped")
raises("inherit_aes_false", on_mtcars(ggplot2::aes(wt, mpg), model, inherit.aes = FALSE),
       "error", "needs both `x` and `y` mapped")
# Raised inside the stat, so ggplot2 turns the error into a "Computation
# failed" warning and draws the plot without the line.
raises("discrete_x", function() {
  ggplot2::ggplot(mpg, ggplot2::aes(drv, hwy)) + geom_slice(lm(hwy ~ drv, mpg))
}, "warning", "needs a continuous x-axis", format = FALSE)
raises("x_uses_no_predictor", on_mtcars(ggplot2::aes(drat, mpg), lm(mpg ~ wt, mtcars)),
       c("warning", "message"), "uses none of the model's predictors")
raises("bare_group", on_mtcars(ggplot2::aes(wt, mpg, group = cyl), lm(mpg ~ wt + cyl, mtcars)),
       c("warning", "message"), "cannot pin `cyl`")
raises("continuous_colour", on_mtcars(ggplot2::aes(wt, mpg, colour = hp), model),
       c("warning", "message"), "is on a continuous scale")
raises("predict_vars_on_x", on_mtcars(ggplot2::aes(wt, mpg), model, predict_vars = list(wt = 3, hp = 100)),
       "warning", "is ignored because it is on the x-axis")
raises("unsupported_class", function() {
  d <- data.frame(x = 1:6, flag = c(TRUE, FALSE, TRUE, TRUE, FALSE, FALSE), y = c(1, 3, 2, 5, 4, 6))
  ggplot2::ggplot(d, ggplot2::aes(x, y)) + geom_slice(lm(y ~ x + flag, d))
}, "error", 'unsupported class "logical"')
raises("raw_layer_no_mapping", function() {
  ggplot2::ggplot(mtcars, ggplot2::aes(disp, mpg)) +
    ggplot2::layer(stat = StatSlice, geom = GeomSlice, position = "identity",
                   params = list(model = lm(mpg ~ disp, mtcars)))
}, "error", "needs both `x` and `y` mapped")
