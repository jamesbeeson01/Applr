# CASE: le_01_single_predictor
# TYPE: console
# FUNC: lm_equation
# EXPECT: "y = <intercept> + 1*x" with coefficients to 3 significant figures
#         (the exact fit's floating-point intercept is zapped to 0).

source("tests/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
y <- x
model <- lm(y ~ x)

try_show(lm_equation(model))
