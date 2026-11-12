# CASE: num_scale_transforms
# Transformed position scales: the grid is evenly spaced in panel units and
# predicted at data-unit x, and predictions land in panel units.

model <- lm(mpg ~ disp, data = mtcars)

covers("geom_slice.scale-transforms")

test_that("under scale_x_log10() the grid is even on the log axis", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(disp, mpg)) + geom_slice(model, n = 20) +
    ggplot2::scale_x_log10()
  d <- slice_data(p)
  expect_equal(d$x, seq(log10(min(mtcars$disp)), log10(max(mtcars$disp)), length.out = 20))
  expect_equal(d$y, predicted(model, data.frame(disp = 10^d$x)))
})

test_that("under scale_y_log10() predictions are placed in panel units", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(disp, mpg)) + geom_slice(model, n = 20) +
    ggplot2::scale_y_log10()
  d <- slice_data(p)
  expect_equal(d$y, log10(predicted(model, data.frame(disp = d$x))))
})
