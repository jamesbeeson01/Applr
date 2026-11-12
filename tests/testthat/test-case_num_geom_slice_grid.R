# CASE: num_geom_slice_grid
# Where geom_slice() puts its prediction points: n of them, spanning each
# group's own x range unless full_range asks for the panel's.

mpg <- ggplot2::mpg
model <- lm(hwy ~ displ * drv, data = mpg)

covers("geom_slice.n-points", "geom_slice.range-per-group", "geom_slice.full-range",
       "geom_slice.na-in-x", "geom_slice.empty-group")

test_that("each line has exactly n points", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) + geom_slice(lm(mpg ~ wt, mtcars), n = 7)
  expect_equal(nrow(slice_data(p)), 7)
})

test_that("each group's line spans that group's own x range", {
  p <- ggplot2::ggplot(mpg, ggplot2::aes(displ, hwy, colour = drv)) + geom_slice(model)
  d <- slice_data(p)
  for (g in unique(d$group)) {
    lvl <- levels(factor(mpg$drv))[g]
    expect_equal(range(d$x[d$group == g]), range(mpg$displ[mpg$drv == lvl]))
  }
})

test_that("full_range and its alias fullrange span the panel instead", {
  for (layer in list(geom_slice(model, full_range = TRUE), geom_slice(model, fullrange = TRUE))) {
    p <- ggplot2::ggplot(mpg, ggplot2::aes(displ, hwy, colour = drv)) + layer
    d <- slice_data(p)
    for (g in unique(d$group)) expect_equal(range(d$x[d$group == g]), range(mpg$displ))
  }
})

test_that("missing x values don't change the grid's range", {
  df <- data.frame(x = c(1, 2, NA, 4, 5), y = c(2, 4, 5, 8, 11))
  m <- lm(y ~ x, data = df)
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y)) + geom_slice(m)
  d <- suppressWarnings(slice_data(p))
  expect_equal(range(d$x), c(1, 5))
  expect_equal(d$y, predicted(m, data.frame(x = d$x)))
})

test_that("a level with no rows draws nothing and the other lines are intact", {
  df <- data.frame(x = rep(1:5, 2), g = factor(rep(c("a", "b"), each = 5), levels = c("a", "b", "c")))
  df$y <- df$x * ifelse(df$g == "a", 1, 2)
  m <- lm(y ~ x * g, data = df)
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y, colour = g)) + geom_slice(m)
  d <- slice_data(p)
  expect_equal(sort(unique(d$group)), 1:2)
  expect_equal(d$y[d$group == 2], predicted(m, data.frame(x = d$x[d$group == 2], g = "b")))
})
