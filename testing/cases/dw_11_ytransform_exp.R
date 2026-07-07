# CASE: dw_11_ytransform_exp
# TYPE: visual
# FUNC: drawit
# EXPECT: Model exp(y) ~ x_pos (y = log(x_pos)), plotted on the ORIGINAL y
#         scale. NOTE: drawit draws on the TRANSFORMED scale (no
#         back-transform), so review what appears.

source("testing/_setup.R")
set.seed(123)

n <- 50
x_pos <- runif(n, 0, 10)
y <- log(x_pos)
model <- lm(exp(y) ~ x_pos)

plot(x_pos, y, main = "Logarithmic: exp(y) ~ x_pos",
     xlab = "x_pos", ylab = "y", pch = 19, col = "steelblue")
drawit(model, xaxis = "x_pos")
