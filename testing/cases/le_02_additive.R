# CASE: le_02_additive
# TYPE: console
# FUNC: lm_equation
# EXPECT: "y = <intercept> + 1*x + 1*x_pos".

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
x_pos <- runif(n, 0, 10)
y <- x + x_pos
model <- lm(y ~ x + x_pos)

try_show(lm_equation(model))
