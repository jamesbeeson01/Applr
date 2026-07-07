# CASE: s2_08_quadratic
# TYPE: visual
# FUNC: slice_2d
# EXPECT: Model y ~ x + I(x^2). Scatter of x vs y with an upward-opening
#         parabola through the points (not a straight line).

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
y <- x + x^2
model <- lm(y ~ x + I(x^2))

slice_2d(model)
