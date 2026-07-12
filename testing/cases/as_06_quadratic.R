# CASE: as_06_quadratic
# TYPE: visual
# FUNC: add_slice_2d
# EXPECT: Model y ~ x + I(x^2). Scatter of x vs y with an upward-opening
#         parabola through the points (not a straight line).
#         Console message: x_axis not specified, first x variable (x) used.

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
y <- x + x^2
model <- lm(y ~ x + I(x^2))

plot(x, y, main = "Quadratic: y ~ x + I(x^2)",
     xlab = "x", ylab = "y", pch = 19, col = "steelblue")
add_slice_2d(model)
