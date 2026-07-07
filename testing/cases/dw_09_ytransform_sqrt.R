# CASE: dw_09_ytransform_sqrt
# TYPE: visual
# FUNC: drawit
# EXPECT: Model sqrt(y) ~ x_pos (y = x_pos^2), plotted on the ORIGINAL y scale.
#         NOTE: drawit draws on the TRANSFORMED scale (no back-transform), so
#         review what appears.

source("testing/_setup.R")
set.seed(123)

n <- 50
x_pos <- runif(n, 0, 10)
y <- x_pos^2
model <- lm(sqrt(y) ~ x_pos)

plot(x_pos, y, main = "Square: sqrt(y) ~ x_pos",
     xlab = "x_pos", ylab = "y", pch = 19, col = "steelblue")
drawit(model, xaxis = "x_pos")
