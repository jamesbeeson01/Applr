# CASE: num_autoplot
# What autoplot() builds: the model's data as points, a geom_slice() line
# with a confidence ribbon, the axes and groupings it chooses, and a
# subtitle.

mpg <- ggplot2::mpg
model <- lm(hwy ~ displ + drv + cyl, data = mpg)
quiet_autoplot <- function(...) suppressMessages(autoplot(..., summary = FALSE))
expr_of <- function(p, aes) rlang::as_label(p$mapping[[aes]])

covers("autoplot.complete-plot", "autoplot.summary-first", "autoplot.x-first-numeric",
       "autoplot.categorical-to-colour-facet", "autoplot.mapping-any-column",
       "autoplot.dots-to-geom-slice", "autoplot.facet-before-subtitle")

test_that("the plot is points, a slice with a confidence ribbon and a subtitle, and + works", {
  p <- quiet_autoplot(lm(mpg ~ wt + hp, mtcars))
  expect_s3_class(p$layers[[1]]$geom, "GeomPoint")
  expect_s3_class(p$layers[[2]]$stat, "StatSlice")
  d <- slice_data(p)
  ci <- predict(lm(mpg ~ wt + hp, mtcars), data.frame(wt = d$x, hp = mean(mtcars$hp)), interval = "confidence")
  expect_equal(d$ymin, unname(ci[, "lwr"]))
  expect_match(p$labels$subtitle, "^mpg = ")
  expect_equal((p + ggplot2::labs(title = "T"))$labels$title, "T")
})

test_that("summary() prints before the plot is returned, unless summary = FALSE", {
  out <- capture.output(p <- suppressMessages(autoplot(lm(mpg ~ wt, mtcars))))
  expect_true(any(grepl("Residual standard error", out)))
  expect_length(capture.output(quiet_autoplot(lm(mpg ~ wt, mtcars))), 0)
})

test_that("the first numeric predictor goes on x, unless the mapping says otherwise", {
  expect_equal(expr_of(quiet_autoplot(lm(hwy ~ drv + displ, mpg)), "x"), "displ")
  expect_equal(expr_of(quiet_autoplot(model, ggplot2::aes(x = cyl)), "x"), "cyl")
  expect_equal(expr_of(quiet_autoplot(model), "y"), "hwy")
})

test_that("the first categorical-like predictor is colour and the second a facet", {
  p <- quiet_autoplot(model)
  expect_equal(expr_of(p, "colour"), "drv")
  expect_equal(names(p$facet$params$facets), "cyl")
  p <- quiet_autoplot(lm(hwy ~ displ + cyl, mpg))
  expect_equal(expr_of(p, "colour"), "factor(cyl)")
  p <- quiet_autoplot(model, ggplot2::aes(colour = year))
  expect_equal(expr_of(p, "colour"), "year")
})

test_that("a mapping can use a column the model doesn't", {
  p <- quiet_autoplot(lm(mpg ~ wt, mtcars), ggplot2::aes(shape = factor(gear)))
  expect_equal(nrow(ggplot2::layer_data(p, 1)), nrow(mtcars))
  expect_equal(length(unique(ggplot2::layer_data(p, 1)$shape)), 3)
})

test_that("... reaches geom_slice(), and a band drops the default ribbon", {
  d <- slice_data(quiet_autoplot(lm(mpg ~ wt + hp, mtcars), interval = "none",
                                 predict_vars = list(hp = 100)))
  expect_null(d$ymin)
  expect_equal(d$y, predicted(lm(mpg ~ wt + hp, mtcars), data.frame(wt = d$x, hp = 100)))
  d <- slice_data(quiet_autoplot(lm(mpg ~ wt + hp, mtcars), band = "hp"))
  a <- predicted(lm(mpg ~ wt + hp, mtcars), data.frame(wt = d$x, hp = min(mtcars$hp)))
  expect_equal(d$ymax, a)
})

test_that("the automatic facet is not reported as held in the subtitle", {
  s <- quiet_autoplot(model)$labels$subtitle
  expect_false(grepl("cyl =", s, fixed = TRUE))
})
