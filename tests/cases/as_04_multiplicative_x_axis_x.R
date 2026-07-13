# CASE: as_04_multiplicative_x_axis_x
# TYPE: visual
# FUNC: add_slice_2d
# EXPECT: Model y ~ I(x*x_pos), plotted with x alone on the x-axis and
#         x_axis = "x". Review how the slice line handles the product term.
#         Console message: x_pos not specified, held at its mean (~4.8).

source("tests/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
x_pos <- runif(n, 0, 10)
y <- x * x_pos
model <- lm(y ~ I(x * x_pos))

plot(x, y, main = "Multiplicative vs x alone",
     xlab = "x", ylab = "y", pch = 19, col = "steelblue")
add_slice_2d(model, x_axis = "x")
