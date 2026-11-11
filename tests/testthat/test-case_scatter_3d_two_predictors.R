# CASE: scatter_3d_two_predictors
# scatter_3d() on a two-predictor model: the surface is the model's
# prediction over the predictor grid. The widget is judged from three
# camera presets plus live use.

model <- lm(mpg ~ wt + hp, data = mtcars)
widget <- scatter_3d(model, n = 20)

covers("scatter_3d.surface-is-prediction", "scatter_3d.readable-from-any-angle")
judged_output("widget", widget, states = list(
  default = list(eye = list(x = 1.25, y = 1.25, z = 1.25)),
  top = list(eye = list(x = 0, y = 0, z = 2.5)),
  side = list(eye = list(x = 2.5, y = 0, z = 0))
))

test_that("the surface equals the model's prediction over the predictor grid", {
  built <- plotly::plotly_build(widget)$x$data
  surface <- Filter(function(t) identical(t$type, "surface"), built)[[1]]
  grid <- expand.grid(wt = surface$x, hp = surface$y)
  expected <- matrix(predict(model, grid), nrow = length(surface$x))
  expect_equal(matrix(surface$z, nrow = nrow(surface$z)), t(unname(expected)))
})
