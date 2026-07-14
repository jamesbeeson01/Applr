# CASE: s2_26_back_transform_string
# TYPE: visual
# FUNC: slice_2d
# EXPECT: Model log(y) ~ x with back_transform = "log": an exponential curve
#         through the raw-scale points, identical to what the auto-detected
#         back-transform (s2_11-style) would draw. Silent: x_axis specified,
#         nothing held.

source("tests/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, 0, 5)
y <- exp(0.6 * x + rnorm(n, 0, 0.2))
model <- lm(log(y) ~ x)

slice_2d(model, x_axis = "x", back_transform = "log")
