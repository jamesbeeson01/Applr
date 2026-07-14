# CASE: le_01_single_predictor
# TYPE: console
# FUNC: lm_equation
# EXPECT: "y = <intercept> + 1*x" with coefficients to 3 significant figures
#         (intercept ~0 in scientific notation is fine).

source("tests/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
y <- x
model <- lm(y ~ x)

try_show(lm_equation(model))
