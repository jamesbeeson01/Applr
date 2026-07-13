# CASE: s2_04_multiplicative
# TYPE: visual
# FUNC: slice_2d
# EXPECT: Model y ~ I(x*x_pos). Default slice_2d plot: raw x on the x-axis
#         (the default is the first x VARIABLE, not the product term — see
#         s2_06 for x_axis = the product) with x_pos held at its mean (~4.8,
#         console message + caption). One straight slice line of slope ~4.8
#         through the middle of the point cloud. A second console message
#         reports x_axis defaulting to x.

source("tests/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
x_pos <- runif(n, 0, 10)
y <- x * x_pos
model <- lm(y ~ I(x * x_pos))

slice_2d(model)
