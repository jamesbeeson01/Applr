# CASE: s2_10_ytransform_sqrt
# TYPE: visual
# FUNC: slice_2d
# EXPECT: Model sqrt(y) ~ x_pos (y = x_pos^2). Plot on the ORIGINAL y scale
#         with a back-transformed upward parabola. Straight line = FAIL.
#         Console message: x_axis not specified, first x variable (x_pos) used.

source("tests/_setup.R")
set.seed(123)

n <- 50
x_pos <- runif(n, 0, 10)
y <- x_pos^2
model <- lm(sqrt(y) ~ x_pos)

slice_2d(model)
