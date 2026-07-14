# CASE: gs_19_x_axis_product
# TYPE: visual
# FUNC: geom_slice
# EXPECT: Model y ~ I(x * x_pos), plotted with the product x * x_pos on the
#         x-axis. Data is noise-free (y = x * x_pos exactly, R^2 = 1), so the
#         slice must be ONE straight line of slope 1 through the origin,
#         passing exactly through every point. No errors.

source("tests/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
x_pos <- runif(n, 0, 10)
y <- x * x_pos
model <- lm(y ~ I(x * x_pos))

p <- ggplot(data.frame(x, x_pos, y), aes(x * x_pos, y)) +
  geom_point(color = "steelblue") +
  geom_slice(model) +
  labs(title = "gs_19: Product on the x-axis (y ~ I(x * x_pos))",
       subtitle = "EXPECT: Straight line, slope 1, exactly through all points")
p
