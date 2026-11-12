# CASE: num_composite_x
# An x-axis expression of several predictors: predictions at the model's own
# data rows, each placed at that row's expression value; n and full_range
# don't apply.

set.seed(2)
df <- data.frame(x = runif(30, 0, 5), x2 = runif(30, 0, 5), g = rep(c("a", "b"), 15))
df$y <- 1 + 2 * df$x * df$x2 + ifelse(df$g == "a", 0, 3) + rnorm(30, sd = 0.1)
model <- lm(y ~ x:x2 + g, data = df)

covers("shared.composite-x.at-data-points", "shared.composite-x.full-range-ignored")

test_that("geom_slice() predicts at each data row of the group, placed at x * x2", {
  p <- ggplot2::ggplot(df, ggplot2::aes(x * x2, y, colour = g)) + geom_slice(model, n = 5)
  d <- slice_data(p)
  for (g in c("a", "b")) {
    rows <- df[df$g == g, ]
    rows <- rows[order(rows$x * rows$x2), ]
    line <- d[d$group == match(g, c("a", "b")), ]
    expect_equal(nrow(line), nrow(rows))
    expect_equal(line$x, rows$x * rows$x2)
    expect_equal(line$y, predicted(model, rows))
  }
  wide <- slice_data(ggplot2::ggplot(df, ggplot2::aes(x * x2, y, colour = g)) +
                       geom_slice(model, n = 5, full_range = TRUE))
  expect_equal(wide, d)
})

test_that("slice_2d() does the same for x_axis = \"x * x2\"", {
  prep <- suppressMessages(prepare_slice_data(model, "x * x2", 5, TRUE, "none", list(g = "b")))
  rows <- df[order(df$x * df$x2), ]
  rows$g <- "b"
  expect_equal(prep$line$x, rows$x * rows$x2)
  expect_equal(prep$line$fit, predicted(model, rows))
})
