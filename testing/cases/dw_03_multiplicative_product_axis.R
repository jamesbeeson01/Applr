# CASE: dw_03_multiplicative_product_axis
# TYPE: visual
# FUNC: drawit
# EXPECT: Model y ~ I(x*x_pos), plotted with the product on the x-axis and
#         xaxis = "I(x * x_pos)": a straight line of slope ~1.
#         KNOWN ISSUE: currently errors "'expr' must be a function, or a call
#         or an expression containing 'I(x * x_pos)'" — curve() cannot use an
#         I() term as its xname.

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
x_pos <- runif(n, 0, 10)
y <- x * x_pos
model <- lm(y ~ I(x * x_pos))

plot(x * x_pos, y, main = "Multiplicative: y ~ I(x*x_pos)",
     xlab = "x*x_pos", ylab = "y", pch = 19, col = "steelblue")
drawit(model, xaxis = "I(x * x_pos)")
