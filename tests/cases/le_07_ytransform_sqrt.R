# CASE: le_07_ytransform_sqrt
# TYPE: console
# FUNC: lm_equation
# EXPECT: The transformed response on the left-hand side:
#         "sqrt(y) = ... + 1*x_pos".

source("testing/_setup.R")
set.seed(123)

n <- 50
x_pos <- runif(n, 0, 10)
y <- x_pos^2
model <- lm(sqrt(y) ~ x_pos)

try_show(lm_equation(model))
