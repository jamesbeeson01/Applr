# CASE: le_08_ytransform_log
# TYPE: console
# FUNC: lm_equation
# EXPECT: The transformed response on the left-hand side:
#         "log(y) = ... + 1*x_pos".

source("tests/_setup.R")
set.seed(123)

n <- 50
x_pos <- runif(n, 0, 10)
y <- exp(x_pos)
model <- lm(log(y) ~ x_pos)

try_show(lm_equation(model))
