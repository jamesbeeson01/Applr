test_that("geom_fit() is removed and points to geom_slice()", {
  expect_error(geom_fit(), "geom_slice")
})

test_that("drawit() warns and still draws", {
  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off(), add = TRUE)
  m <- lm(mpg ~ disp, data = mtcars)
  expect_warning(drawit(m, xaxis = "disp"))
})
