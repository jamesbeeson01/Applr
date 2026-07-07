# CASE: gs_23_xaxis_composite_product
# TYPE: visual
# FUNC: geom_slice
# EXPECT: Model y ~ x2:x3:x6 + x1:x2:x3, plotted with the composite expression
#         x2 * x3 * (x1 + x6) on the x-axis. Data is noise-free
#         (y = x2*x3*(x1+x6) = x1*x2*x3 + x2*x3*x6 exactly, R^2 = 1), so the
#         slice must be ONE straight line of slope 1 through the origin,
#         passing exactly through every point. No errors.

source("testing/_setup.R")
set.seed(123)

n <- 50
x1 <- runif(n, -5, 5)
x2 <- runif(n, -5, 5)
x3 <- runif(n, -5, 5)
x6 <- runif(n, -5, 5)
y <- x2 * x3 * (x1 + x6)
model <- lm(y ~ x2:x3:x6 + x1:x2:x3)

p <- ggplot(data.frame(x1, x2, x3, x6, y), aes(x2 * x3 * (x1 + x6), y)) +
  geom_point(color = "steelblue") +
  geom_slice(model) +
  labs(title = "gs_23: Composite product axis (y ~ x2:x3:x6 + x1:x2:x3)",
       subtitle = "EXPECT: Straight line, slope 1, exactly through all points")
p
