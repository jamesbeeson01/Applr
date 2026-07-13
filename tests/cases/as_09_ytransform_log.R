# CASE: as_09_ytransform_log
# TYPE: visual
# FUNC: add_slice_2d
# EXPECT: Model log(y) ~ x_pos (y = exp(x_pos)), plotted on the ORIGINAL y
#         scale. Back-transformed exponential curve. Straight line = FAIL.
#         Console message: x_axis not specified, first x variable (x_pos) used.

source("testing/_setup.R")
set.seed(123)

n <- 50
x_pos <- runif(n, 0, 10)
y <- exp(x_pos)
model <- lm(log(y) ~ x_pos)

plot(x_pos, y, main = "Exponential: log(y) ~ x_pos",
     xlab = "x_pos", ylab = "y", pch = 19, col = "steelblue")
add_slice_2d(model)
