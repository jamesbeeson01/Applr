# CASE: dw_13_err_non_lm
# TYPE: console
# FUNC: drawit
# EXPECT: A clear error rejecting the non-lm object. Currently fails earlier
#         with "argument \"xaxis\" is missing, with no default" (xaxis is a
#         required argument) — a model-type check would be friendlier.

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
y <- x
not_a_model <- data.frame(y = c(1, 2, 3), x = c(4, 5, 6))

plot(x, y, main = "scaffold plot")
try_show(drawit(not_a_model))
