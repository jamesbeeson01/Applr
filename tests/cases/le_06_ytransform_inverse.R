# CASE: le_06_ytransform_inverse
# TYPE: console
# FUNC: lm_equation
# EXPECT: The transformed response on the left-hand side: "1/y = ... + 1*x".

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
y <- 1/x
model <- lm(1/y ~ x)

try_show(lm_equation(model))
