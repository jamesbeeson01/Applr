m_simple <- lm(mpg ~ disp, data = mtcars)
m_two <- lm(mpg ~ disp + hp, data = mtcars)

test_that("autoplot() builds a ggplot and summary = FALSE keeps it quiet", {
  expect_silent(p <- ggplot2::autoplot(m_simple, summary = FALSE))
  expect_s3_class(p, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("autoplot() prints the model summary by default", {
  expect_output(ggplot2::autoplot(m_simple), "Residual standard error")
})

test_that("slice_2d() and add_slice_2d() draw in base graphics", {
  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off(), add = TRUE)
  expect_no_error(slice_2d(m_simple, x_axis = "disp"))
  expect_no_error(slice_2d(m_simple, x_axis = "disp", interval = "confidence"))
  plot(mpg ~ disp, data = mtcars)
  expect_no_error(add_slice_2d(m_two, x_axis = "disp", hp = 100))
})

test_that("slice_2d() errors on an x_axis not in the model", {
  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off(), add = TRUE)
  expect_error(slice_2d(m_simple, x_axis = "nope"), "not found in the model")
})

test_that("scatter_3d() returns a plotly widget", {
  expect_s3_class(scatter_3d(m_two), "plotly")
})

test_that("theme_lc() returns a ggplot2 theme", {
  expect_s3_class(theme_lc(), "theme")
})
