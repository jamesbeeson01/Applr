# CASE: single_predictor_line
# A one-predictor model: the plotted line is the model's prediction, and the
# plot as a whole is judged.

set.seed(1)
df <- data.frame(x = runif(50, -10, 10))
df$y <- 2 * df$x + 3 + rnorm(50)
model <- lm(y ~ x, data = df)

p <- ggplot2::ggplot(df, ggplot2::aes(x, y)) +
  ggplot2::geom_point() +
  geom_slice(model) +
  ggplot2::labs(title = "Single predictor")

judged_output("plot", p)

test_that("the plotted line equals the model's prediction on the expected grid", {
  d <- ggplot2::ggplot_build(p)$data[[2]]
  grid <- seq(min(df$x), max(df$x), length.out = 100)
  expect_equal(d$x, grid)
  expect_equal(d$y, unname(predict(model, data.frame(x = grid))))
})
