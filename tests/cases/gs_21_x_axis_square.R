# CASE: gs_21_x_axis_square
# TYPE: visual
# FUNC: geom_slice
# EXPECT: Model y ~ I(x^2), plotted with x^2 on the x-axis. Data is noise-free
#         (y = 2*x^2 + 1 exactly, R^2 = 1), so the slice must be ONE straight
#         line of slope 2 and intercept 1, passing exactly through every
#         point. No errors.

source("tests/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -5, 5)
y <- 2 * x^2 + 1
model <- lm(y ~ I(x^2))

p <- ggplot(data.frame(x, y), aes(x^2, y)) +
  geom_point(color = "steelblue") +
  geom_slice(model) +
  labs(title = "gs_21: x^2 on the x-axis (y ~ I(x^2))",
       subtitle = "EXPECT: Straight line, slope 2, exactly through all points")
p
