# CASE: s2_11_ytransform_log
# TYPE: visual
# FUNC: slice_2d
# EXPECT: Model log(y) ~ x_pos (y = exp(x_pos)). Plot on the ORIGINAL y scale
#         with a back-transformed exponential curve. Straight line = FAIL.

source("testing/_setup.R")
set.seed(123)

n <- 50
x_pos <- runif(n, 0, 10)
y <- exp(x_pos)
model <- lm(log(y) ~ x_pos)

slice_2d(model)
