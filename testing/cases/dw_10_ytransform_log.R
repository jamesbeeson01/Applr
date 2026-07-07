# CASE: dw_10_ytransform_log
# TYPE: visual
# FUNC: drawit
# EXPECT: Model log(y) ~ x_pos (y = exp(x_pos)), plotted on the ORIGINAL y
#         scale. NOTE: drawit draws on the TRANSFORMED scale (no
#         back-transform), so review what appears.

source("testing/_setup.R")
set.seed(123)

n <- 50
x_pos <- runif(n, 0, 10)
y <- exp(x_pos)
model <- lm(log(y) ~ x_pos)

plot(x_pos, y, main = "Exponential: log(y) ~ x_pos",
     xlab = "x_pos", ylab = "y", pch = 19, col = "steelblue")
drawit(model, xaxis = "x_pos")
