# CASE: le_13_factor_raw
# TYPE: console
# FUNC: lm_equation
# EXPECT: with style = "raw", factor terms shown as dummy coefficient
#         names (gB, gC, x:gB, x:gC) — raw design-matrix names.

source("tests/_setup.R")
set.seed(123)

n <- 60
x <- runif(n, -10, 10)
g <- factor(sample(c("A", "B", "C"), n, replace = TRUE))
y <- 2 + 0.5 * x + 4 * (g == "B") - 3 * (g == "C") + 0.8 * x * (g == "B") + rnorm(n)
model <- lm(y ~ x * g)

try_show(lm_equation(model, style = "raw"))
