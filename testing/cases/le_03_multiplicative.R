# CASE: le_03_multiplicative
# TYPE: console
# FUNC: lm_equation
# EXPECT: "y = <intercept> + 1*I(x * x_pos)" — the I() term shown as-is.

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
x_pos <- runif(n, 0, 10)
y <- x * x_pos
model <- lm(y ~ I(x * x_pos))

try_show(lm_equation(model))
