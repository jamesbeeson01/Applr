# CASE: as_02_additive_default
# TYPE: visual
# FUNC: add_slice_2d
# EXPECT: Base scatter of x vs y (y ~ x + x_pos) with one straight slice line,
#         x_pos held at its default (mean ~4.8, with a console message).
#         Line should sit near the center of the point cloud.

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
x_pos <- runif(n, 0, 10)
y <- x + x_pos
model <- lm(y ~ x + x_pos)

plot(x, y, main = "Additive: y ~ x + x_pos",
     xlab = "x", ylab = "y", pch = 19, col = "steelblue")
add_slice_2d(model)
