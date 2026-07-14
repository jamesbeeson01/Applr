# CASE: le_04_interaction
# TYPE: console
# FUNC: lm_equation
# EXPECT: "y = <intercept> + 1*x:x_switch" — the interaction term shown as-is.

source("tests/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
x_switch <- sample(c(0, 1, 2), n, replace = TRUE)
y <- x * x_switch
model <- lm(y ~ x:x_switch)

try_show(lm_equation(model))
