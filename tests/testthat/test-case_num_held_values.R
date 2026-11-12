# CASE: num_held_values
# Predictors the user names are held at the values given; several values
# give one line per value, and several multi-value variables are crossed.

mpg <- ggplot2::mpg
model <- lm(hwy ~ displ + cyl + drv, data = mpg)
base <- ggplot2::ggplot(mpg, ggplot2::aes(displ, hwy))

covers("shared.held-values.single", "shared.held-values.multi-crossed",
       "shared.held-values.coerced", "shared.held-values.beats-pinning",
       "shared.held-values.base-not-coerced", "slice_2d.held-named-x")

test_that("a held predictor is held at that value along the whole line", {
  d <- slice_data(base + geom_slice(model, n = 10, predict_vars = list(cyl = 6, drv = "r")))
  expect_equal(d$y, predicted(model, data.frame(displ = d$x, cyl = 6, drv = "r")))
})

test_that("several values are crossed into one line per combination, each its own group", {
  d <- slice_data(base + geom_slice(model, n = 10,
                                    predict_vars = list(cyl = c(4, 6, 8), drv = c("f", "r"))))
  expect_equal(length(unique(d$group)), 6)
  combos <- expand.grid(cyl = c(4, 6, 8), drv = c("f", "r"), stringsAsFactors = FALSE)
  for (i in seq_len(nrow(combos))) {
    line <- d[d$group == sort(unique(d$group))[i], ]
    expect_equal(line$y, predicted(model, data.frame(displ = line$x, cyl = combos$cyl[i], drv = combos$drv[i])))
  }
})

test_that("values are coerced to the predictor's type", {
  as_given <- slice_data(base + geom_slice(model, n = 10, predict_vars = list(cyl = "6", drv = "r")))
  typed <- slice_data(base + geom_slice(model, n = 10,
                                        predict_vars = list(cyl = 6, drv = factor("r"))))
  expect_equal(as_given$y, typed$y)
})

test_that("a held value beats the pin a grouping aesthetic or facet would give", {
  coloured <- ggplot2::ggplot(mpg, ggplot2::aes(displ, hwy, colour = drv)) +
    geom_slice(model, n = 10, predict_vars = list(drv = "4", cyl = 4))
  d <- slice_data(coloured)
  expect_equal(d$y[d$group == 1], predicted(model, data.frame(displ = d$x[d$group == 1], cyl = 4, drv = "4")))
  faceted <- base + geom_slice(model, n = 10, predict_vars = list(drv = "4", cyl = 4)) +
    ggplot2::facet_wrap(~drv)
  d <- slice_data(faceted)
  for (panel in unique(d$PANEL)) {
    line <- d[d$PANEL == panel, ]
    expect_equal(line$y, predicted(model, data.frame(displ = line$x, cyl = 4, drv = "4")))
  }
})

test_that("slice_2d() predicts at a factor value given as a string", {
  prep <- suppressMessages(prepare_slice_data(model, "displ", 10, TRUE, "none",
                                              list(cyl = 6, drv = "r")))
  expect_equal(prep$line$fit, predicted(model, data.frame(displ = prep$line$x, cyl = 6, drv = "r")))
})

test_that("a held predictor named x is a held value, not x_axis", {
  d <- data.frame(w = 1:10, x = c(2, 1, 4, 3, 6, 5, 8, 7, 10, 9))
  d$y <- d$w + 2 * d$x
  m <- lm(y ~ w + x, data = d)
  prep <- prepare_slice_data(m, "w", 10, TRUE, "none", list(x = 2))
  expect_equal(prep$line$fit, predicted(m, data.frame(w = prep$line$x, x = 2)))
  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off())
  expect_silent(slice_2d(m, x_axis = "w", x = 2))
})
