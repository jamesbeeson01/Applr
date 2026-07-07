# CASE: as_04_multiplicative_xaxis_x
# TYPE: visual
# FUNC: add_slice_2d
# EXPECT: Model y ~ I(x*x_pos), plotted with x alone on the x-axis and
#         xaxis = "x". Review how the slice line handles the product term.

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
x_pos <- runif(n, 0, 10)
y <- x * x_pos
model <- lm(y ~ I(x * x_pos))

plot(x, y, main = "Multiplicative vs x alone",
     xlab = "x", ylab = "y", pch = 19, col = "steelblue")
add_slice_2d(model, xaxis = "x")
