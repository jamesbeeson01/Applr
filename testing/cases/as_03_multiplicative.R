# CASE: as_03_multiplicative
# TYPE: visual
# FUNC: add_slice_2d
# EXPECT: Model y ~ I(x*x_pos), plotted with the product x*x_pos on the x-axis.
#         x_axis = "x * x_pos" (composite mode) draws one straight slice line
#         of slope ~1 through the points. Silent: every predictor is on the
#         x-axis, nothing is held. (The default x_axis would pick the first
#         raw variable `x` — wrong for this plot — so it is specified.)

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
x_pos <- runif(n, 0, 10)
y <- x * x_pos
model <- lm(y ~ I(x * x_pos))

plot(x * x_pos, y, main = "Multiplicative: y ~ I(x*x_pos)",
     xlab = "x*x_pos", ylab = "y", pch = 19, col = "steelblue")
add_slice_2d(model, x_axis = "x * x_pos")
