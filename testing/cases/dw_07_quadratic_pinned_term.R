# CASE: dw_07_quadratic_pinned_term
# TYPE: visual
# FUNC: drawit
# EXPECT: Model y ~ x + I(x^2) with the quadratic term PINNED: `I(x^2)` = 50.
#         The drawn curve becomes a straight line (slope ~1, shifted up by
#         ~50 * the I(x^2) coefficient), cutting through the parabola of points.

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
y <- x + x^2
model <- lm(y ~ x + I(x^2))

plot(x, y, main = "Quadratic with I(x^2) pinned at 50",
     xlab = "x", ylab = "y", pch = 19, col = "steelblue")
drawit(model, xaxis = "x", `I(x^2)` = 50)
