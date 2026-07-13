# CASE: le_05_quadratic
# TYPE: console
# FUNC: lm_equation
# EXPECT: "y = <intercept> + 1*x + 1*I(x^2)".

source("tests/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
y <- x + x^2
model <- lm(y ~ x + I(x^2))

try_show(lm_equation(model))
