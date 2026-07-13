# CASE: s2_13_ytransform_square
# TYPE: visual
# FUNC: slice_2d
# EXPECT: Model y^2 ~ x_pos (y = sqrt(x_pos)). Plot on the ORIGINAL y scale
#         with a back-transformed square-root curve. Straight line = FAIL.
#         Console message: x_axis not specified, first x variable (x_pos) used.

source("tests/_setup.R")
set.seed(123)

n <- 50
x_pos <- runif(n, 0, 10)
y <- sqrt(x_pos)
model <- lm(y^2 ~ x_pos)

slice_2d(model)
