# CASE: s2_09_ytransform_inverse
# TYPE: visual
# FUNC: slice_2d
# EXPECT: Model 1/y ~ x. Plot on the ORIGINAL y scale with a back-transformed
#         hyperbolic slice line. A straight line means back-transform failed.
#         Console message: xaxis not specified, first x variable (x) used.

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
y <- 1/x
model <- lm(1/y ~ x)

slice_2d(model)
