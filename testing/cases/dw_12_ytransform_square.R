# CASE: dw_12_ytransform_square
# TYPE: visual
# FUNC: drawit
# EXPECT: Model y^2 ~ x_pos (y = sqrt(x_pos)), plotted on the ORIGINAL y
#         scale. NOTE: drawit draws on the TRANSFORMED scale (no
#         back-transform), so review what appears.

source("testing/_setup.R")
set.seed(123)

n <- 50
x_pos <- runif(n, 0, 10)
y <- sqrt(x_pos)
model <- lm(y^2 ~ x_pos)

plot(x_pos, y, main = "Square Root: y^2 ~ x_pos",
     xlab = "x_pos", ylab = "y", pch = 19, col = "steelblue")
drawit(model, xaxis = "x_pos")
