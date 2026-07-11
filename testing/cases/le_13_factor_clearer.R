# CASE: le_13_factor_clearer
# TYPE: console
# FUNC: lm_equation, lm_latex
# EXPECT: with clearer = TRUE, factor terms spell out variable and level —
#         (g="B"), (g="C"), and interactions as x:(g="B"), x:(g="C").

source("testing/_setup.R")
set.seed(123)

n <- 60
x <- runif(n, -10, 10)
g <- factor(sample(c("A", "B", "C"), n, replace = TRUE))
y <- 2 + 0.5 * x + 4 * (g == "B") - 3 * (g == "C") + 0.8 * x * (g == "B") + rnorm(n)
model <- lm(y ~ x * g)

try_show(lm_equation(model, clearer = TRUE))
try_show(lm_latex(model, clearer = TRUE))
