# CASE: s2_04_multiplicative
# TYPE: visual
# FUNC: slice_2d
# EXPECT: Model y ~ I(x*x_pos). Default slice_2d plot: the product term on the
#         x-axis with a straight slice line of slope ~1 through the points.

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
x_pos <- runif(n, 0, 10)
y <- x * x_pos
model <- lm(y ~ I(x * x_pos))

slice_2d(model)
