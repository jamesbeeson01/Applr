# CASE: gs_20_x_axis_log
# TYPE: visual
# FUNC: geom_slice
# EXPECT: Model y ~ log(x), plotted with log(x) on the x-axis. Data is
#         noise-free (y = 3*log(x) + 2 exactly, R^2 = 1), so the slice must be
#         ONE straight line of slope 3 and intercept 2, passing exactly
#         through every point. No errors.

source("tests/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, 0.5, 20)
y <- 3 * log(x) + 2
model <- lm(y ~ log(x))

p <- ggplot(data.frame(x, y), aes(log(x), y)) +
  geom_point(color = "steelblue") +
  geom_slice(model) +
  labs(title = "gs_20: log(x) on the x-axis (y ~ log(x))",
       subtitle = "EXPECT: Straight line, slope 3, exactly through all points")
p
