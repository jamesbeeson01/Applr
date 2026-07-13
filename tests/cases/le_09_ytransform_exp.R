# CASE: le_09_ytransform_exp
# TYPE: console
# FUNC: lm_equation
# EXPECT: The transformed response on the left-hand side:
#         "exp(y) = ... + 1*x_pos".

source("testing/_setup.R")
set.seed(123)

n <- 50
x_pos <- runif(n, 0, 10)
y <- log(x_pos)
model <- lm(exp(y) ~ x_pos)

try_show(lm_equation(model))
