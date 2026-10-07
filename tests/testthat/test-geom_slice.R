build_layer <- function(p, i = 1) ggplot2::ggplot_build(p)$data[[i]]

m_simple <- lm(mpg ~ disp, data = mtcars)
m_two <- lm(mpg ~ disp + hp, data = mtcars)
base <- ggplot2::ggplot(mtcars, ggplot2::aes(disp, mpg))

test_that("geom_slice() returns a ggplot2 layer", {
  expect_s3_class(geom_slice(m_simple), "Layer")
})

test_that("the slice matches predict() across the data range", {
  d <- build_layer(base + geom_slice(m_simple))
  expect_equal(nrow(d), 100)
  expect_equal(range(d$x), range(mtcars$disp))
  expect_equal(d$y, unname(predict(m_simple, data.frame(disp = d$x))))
})

test_that("predict_vars holds other predictors at the given value", {
  d <- build_layer(base + geom_slice(m_two, predict_vars = list(hp = 150)))
  expect_equal(d$y, unname(predict(m_two, data.frame(disp = d$x, hp = 150))))
})

test_that("multiple predict_vars values draw one line each", {
  d <- build_layer(base + geom_slice(m_two, predict_vars = list(hp = c(100, 200))))
  expect_length(unique(d$group), 2)
})

test_that("interval = 'confidence' adds a band around the line", {
  d <- build_layer(base + geom_slice(m_simple, interval = "confidence"))
  expect_true(all(c("ymin", "ymax") %in% names(d)))
  expect_true(all(d$ymin < d$y & d$y < d$ymax))
})

test_that("a log response is back-transformed to the plotted scale", {
  m_log <- lm(log(mpg) ~ disp, data = mtcars)
  expect_message(d <- build_layer(base + geom_slice(m_log)), "back-transformed")
  expect_equal(d$y, unname(exp(predict(m_log, data.frame(disp = d$x)))))
})

test_that("geom_slice() rejects non-lm input", {
  expect_error(ggplot2::ggplot_build(base + geom_slice("x")), "fitted by `lm\\(\\)`")
})
