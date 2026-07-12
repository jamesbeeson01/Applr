# CASE: dw_04_multiplicative_xaxis_x
# TYPE: visual
# FUNC: drawit
# EXPECT: Model y ~ I(x*x_pos), plotted with x alone on the x-axis and
#         xaxis = "x". Review how the drawn curve handles the product term.
#         UNRESOLVED: drawit currently emits a raw warning ("I(x * x_pos)
#         value not specified; enter value between:<min>-<max>") with
#         full-precision numbers mashed together (ambiguous with negative
#         values). Decide whether drawit should message like slice_2d
#         before snapshotting this output.

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
x_pos <- runif(n, 0, 10)
y <- x * x_pos
model <- lm(y ~ I(x * x_pos))

plot(x, y, main = "Multiplicative vs x alone",
     xlab = "x", ylab = "y", pch = 19, col = "steelblue")
drawit(model, xaxis = "x")
