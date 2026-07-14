# CASE: gs_26_inline_log_y
# TYPE: visual
# FUNC: geom_slice
# EXPECT: Model log(y) ~ x, plotted with log(y) mapped inline on the y-axis
#         (aes(x, log(y))). Data is noise-free (y = exp(0.5*x + 1) exactly,
#         R^2 = 1). Because the y-axis already shows log(y), predictions must
#         NOT be back-transformed: the slice must be ONE straight line of
#         slope 0.5 and intercept 1, passing exactly through every point.
#         A curved (exponential) line means it wrongly back-transformed.
#         No errors.

source("tests/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, 0, 10)
y <- exp(0.5 * x + 1)
model <- lm(log(y) ~ x)

p <- ggplot(data.frame(x, y), aes(x, log(y))) +
  geom_point(color = "steelblue") +
  geom_slice(model) +
  labs(title = "gs_26: Inline log(y) on the y-axis (log(y) ~ x)",
       subtitle = "EXPECT: Straight line, slope 0.5, exactly through all points")
p
