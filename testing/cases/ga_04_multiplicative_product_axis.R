# CASE: ga_04_multiplicative_product_axis
# TYPE: visual
# FUNC: geom_add_slice_2d
# EXPECT: Model y ~ I(x*x_pos), plotted with the product x*x_pos on the
#         x-axis. One straight slice line of slope ~1.

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
x_pos <- runif(n, 0, 10)
y <- x * x_pos
model <- lm(y ~ I(x * x_pos))

ggplot(data.frame(x, x_pos, y), aes(x * x_pos, y)) +
  geom_point() +
  geom_add_slice_2d(model)
