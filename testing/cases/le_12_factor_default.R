# CASE: le_12_factor_default
# TYPE: console
# FUNC: lm_equation, lm_latex
# EXPECT: factor terms shown as dummy coefficient names (gB, gC, x:gB, x:gC)
#         — the default (clearer unspecified) keeps design-matrix names.

source("testing/_setup.R")
set.seed(123)

n <- 60
x <- runif(n, -10, 10)
g <- factor(sample(c("A", "B", "C"), n, replace = TRUE))
y <- 2 + 0.5 * x + 4 * (g == "B") - 3 * (g == "C") + 0.8 * x * (g == "B") + rnorm(n)
model <- lm(y ~ x * g)

try_show(lm_equation(model))
try_show(lm_latex(model))
