# CASE: as_11_ytransform_square
# TYPE: visual
# FUNC: add_slice_2d
# EXPECT: Model y^2 ~ x_pos (y = sqrt(x_pos)), plotted on the ORIGINAL y
#         scale. Back-transformed square-root curve. Straight line = FAIL.
#         Console message: xaxis not specified, first x variable (x_pos) used.

source("testing/_setup.R")
set.seed(123)

n <- 50
x_pos <- runif(n, 0, 10)
y <- sqrt(x_pos)
model <- lm(y^2 ~ x_pos)

plot(x_pos, y, main = "Square Root: y^2 ~ x_pos",
     xlab = "x_pos", ylab = "y", pch = 19, col = "steelblue")
add_slice_2d(model)
