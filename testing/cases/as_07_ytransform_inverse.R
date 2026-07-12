# CASE: as_07_ytransform_inverse
# TYPE: visual
# FUNC: add_slice_2d
# EXPECT: Model 1/y ~ x, plotted on the ORIGINAL y scale. Back-transformed
#         hyperbolic slice line. A straight line means back-transform failed.
#         Console message: x_axis not specified, first x variable (x) used.

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
y <- 1/x
model <- lm(1/y ~ x)

plot(x, y, main = "Inverse: 1/y ~ x",
     xlab = "x", ylab = "y", pch = 19, col = "steelblue")
add_slice_2d(model)
