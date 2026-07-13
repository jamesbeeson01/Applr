# CASE: le_10_ytransform_square
# TYPE: console
# FUNC: lm_equation
# EXPECT: The transformed response on the left-hand side:
#         "y^2 = ... + 1*x_pos".

source("testing/_setup.R")
set.seed(123)

n <- 50
x_pos <- runif(n, 0, 10)
y <- sqrt(x_pos)
model <- lm(y^2 ~ x_pos)

try_show(lm_equation(model))
