# CASE: dw_06_quadratic
# TYPE: visual
# FUNC: drawit
# EXPECT: Model y ~ x + I(x^2). Scatter of x vs y with an upward-opening
#         parabola drawn through the points.
#         UNRESOLVED: drawit currently emits a raw warning ("I(x^2) value
#         not specified; enter value between:<min>-<max>") with
#         full-precision numbers mashed together. Decide whether drawit
#         should message like slice_2d before snapshotting this output.

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
y <- x + x^2
model <- lm(y ~ x + I(x^2))

plot(x, y, main = "Quadratic: y ~ x + I(x^2)",
     xlab = "x", ylab = "y", pch = 19, col = "steelblue")
drawit(model, xaxis = "x")
