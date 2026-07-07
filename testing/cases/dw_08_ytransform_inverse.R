# CASE: dw_08_ytransform_inverse
# TYPE: visual
# FUNC: drawit
# EXPECT: Model 1/y ~ x, plotted on the ORIGINAL y scale. NOTE: drawit draws
#         on the TRANSFORMED scale (no back-transform), so review what appears
#         — the line will not follow the hyperbolic points.

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
y <- 1/x
model <- lm(1/y ~ x)

plot(x, y, main = "Inverse: 1/y ~ x",
     xlab = "x", ylab = "y", pch = 19, col = "steelblue")
drawit(model, xaxis = "x")
