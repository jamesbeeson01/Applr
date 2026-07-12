# CASE: as_03_multiplicative
# TYPE: visual
# FUNC: add_slice_2d
# EXPECT: Model y ~ I(x*x_pos), plotted with the product x*x_pos on the x-axis.
#         One straight slice line of slope ~1 through the points.
#         UNRESOLVED: the console currently reports xaxis defaulting to `x`
#         (not the product) and x_pos held at its mean (~4.8), so the slice
#         is computed against raw x — inconsistent with the slope-~1
#         expectation above. Related to the product-term known issues
#         (s2_06, dw_03). No snapshot until this is decided.

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
x_pos <- runif(n, 0, 10)
y <- x * x_pos
model <- lm(y ~ I(x * x_pos))

plot(x * x_pos, y, main = "Multiplicative: y ~ I(x*x_pos)",
     xlab = "x*x_pos", ylab = "y", pch = 19, col = "steelblue")
add_slice_2d(model)
