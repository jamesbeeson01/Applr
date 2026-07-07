# CASE: s2_03_additive_xaxis_xpos
# TYPE: visual
# FUNC: slice_2d
# EXPECT: Scatter of x_pos vs y (y ~ x + x_pos) with a slice line, x held at 0.
#         KNOWN ISSUE: currently errors "xaxis variable '0' not found in the
#         model." — the x = 0 argument passed via ... is mishandled.

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
x_pos <- runif(n, 0, 10)
y <- x + x_pos
model <- lm(y ~ x + x_pos)

slice_2d(model, xaxis = "x_pos", x = 0)
