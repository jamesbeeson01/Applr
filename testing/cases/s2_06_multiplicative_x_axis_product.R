# CASE: s2_06_multiplicative_x_axis_product
# TYPE: visual
# FUNC: slice_2d
# EXPECT: Model y ~ I(x*x_pos) with x_axis = "x*x_pos" (the product itself):
#         same shape as the default plot in s2_04 — a composite x-axis, so
#         predictions are made at the data points and placed at x*x_pos.
#         Silent: every predictor is on the x-axis, nothing is held.

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
x_pos <- runif(n, 0, 10)
y <- x * x_pos
model <- lm(y ~ I(x * x_pos))

slice_2d(model, x_axis = "x*x_pos")
