# CASE: cond_slice_2d
# Conditions from the base graphics functions: the x-axis, data changed
# since the fit, a slice outside the plot, no plot open, and the deprecated
# xaxis argument.

model <- lm(mpg ~ wt + hp, data = mtcars)
on_device <- function(code) function() {
  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off())
  code()
}

covers("slice_2d.default-x-axis", "slice_2d.x-axis-errors", "shared.model-data.refit-needed",
       "add_slice_2d.outside-plot", "add_slice_2d.no-plot", "shared.conditions.xaxis-deprecated")

raises("x_axis_default", on_device(function() slice_2d(model, hp = 100)), "message",
       "X-axis not specified")
raises("x_axis_not_string", function() slice_2d(model, x_axis = 1), "error",
       "`x_axis` must be the name of one model predictor")
raises("x_axis_not_found", function() slice_2d(model, x_axis = "disp"), "error",
       '`x_axis` variable "disp" not found in the model.')
raises("x_axis_not_numeric", function() {
  slice_2d(lm(Sepal.Length ~ Species + Sepal.Width, iris), x_axis = "Species")
}, "error", '`x_axis` must be numeric; the class "factor"')
raises("data_changed", function() {
  cars <- mtcars
  m <- lm(mpg ~ wt, data = cars)
  cars$mpg <- cars$mpg + 1
  slice_2d(m, x_axis = "wt")
}, "error", "The data being plotted is not the data `m` was fitted to.")
raises("outside_plot", on_device(function() {
  plot(1:2, 1:2)
  add_slice_2d(model, x_axis = "wt", hp = 100)
}), "warning", "Slice is outside the current plot range")
raises("no_plot_open", on_device(function() add_slice_2d(model, x_axis = "wt", hp = 100)),
       c("warning", "error"), "plot.new has not been called yet", format = FALSE)
raises("xaxis_deprecated", on_device(function() slice_2d(model, xaxis = "wt", hp = 100)),
       "warning", "The `xaxis` argument of `slice_2d()` is deprecated.")
raises("xaxis_deprecated_add", on_device(function() {
  plot(mpg ~ wt, mtcars)
  add_slice_2d(model, xaxis = "wt", hp = 100)
}), "warning", "The `xaxis` argument of `add_slice_2d()` is deprecated.")

test_that("when both x_axis and xaxis are given, x_axis wins", {
  prep <- suppressWarnings(suppressMessages(resolve_deprecated_xaxis("hp", "wt", "slice_2d")))
  expect_equal(prep, "hp")
})
