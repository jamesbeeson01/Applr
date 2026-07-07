# CASE: dw_02_additive_predict_var
# TYPE: visual
# FUNC: drawit
# EXPECT: Base scatter of x vs y (y ~ x + x_pos) with a straight line drawn at
#         x_pos = 0.007 — near the BOTTOM of the point cloud (x_pos contributes
#         almost nothing at that value).

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
x_pos <- runif(n, 0, 10)
y <- x + x_pos
model <- lm(y ~ x + x_pos)

plot(x, y, main = "Additive: y ~ x + x_pos",
     xlab = "x", ylab = "y", pch = 19, col = "steelblue")
drawit(model, xaxis = "x", x_pos = 0.007)
