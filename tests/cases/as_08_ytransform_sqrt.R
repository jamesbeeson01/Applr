# CASE: as_08_ytransform_sqrt
# TYPE: visual
# FUNC: add_slice_2d
# EXPECT: Model sqrt(y) ~ x_pos (y = x_pos^2), plotted on the ORIGINAL y scale.
#         Back-transformed upward parabola. Straight line = FAIL.
#         Console message: x_axis not specified, first x variable (x_pos) used.

source("tests/_setup.R")
set.seed(123)

n <- 50
x_pos <- runif(n, 0, 10)
y <- x_pos^2
model <- lm(sqrt(y) ~ x_pos)

plot(x_pos, y, main = "Square: sqrt(y) ~ x_pos",
     xlab = "x_pos", ylab = "y", pch = 19, col = "steelblue")
add_slice_2d(model)
