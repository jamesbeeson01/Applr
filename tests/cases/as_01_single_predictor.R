# CASE: as_01_single_predictor
# TYPE: visual
# FUNC: add_slice_2d
# EXPECT: Base scatter of x vs y with a slice line of slope ~1 overlaid by
#         add_slice_2d(). Console message: x_axis not specified, so the
#         first x variable (x) is used as the x-axis.

source("tests/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
y <- x
model <- lm(y ~ x)

plot(x, y, main = "Single Predictor: y ~ x",
     xlab = "x", ylab = "y", pch = 19, col = "steelblue")
add_slice_2d(model)
