# CASE: as_10_ytransform_exp
# TYPE: visual
# FUNC: add_slice_2d
# EXPECT: Model exp(y) ~ x_pos (y = log(x_pos)), plotted on the ORIGINAL y
#         scale. Back-transformed logarithmic curve. Straight line = FAIL.
#         Console message: x_axis not specified, first x variable (x_pos) used.

source("tests/_setup.R")
set.seed(123)

n <- 50
x_pos <- runif(n, 0, 10)
y <- log(x_pos)
model <- lm(exp(y) ~ x_pos)

plot(x_pos, y, main = "Logarithmic: exp(y) ~ x_pos",
     xlab = "x_pos", ylab = "y", pch = 19, col = "steelblue")
add_slice_2d(model)
