# CASE: la_03_factor_brackets
# TYPE: console
# FUNC: lm_latex
# EXPECT: display-math LaTeX with underbrace labels; with format = "brackets"
#         (abbreviated to "bracket" here, which partial-matches), factor terms
#         are labelled by level alone — [B], [C], x:[B], x:[C].

source("tests/_setup.R")
set.seed(123)

n <- 60
x <- runif(n, -10, 10)
g <- factor(sample(c("A", "B", "C"), n, replace = TRUE))
y <- 2 + 0.5 * x + 4 * (g == "B") - 3 * (g == "C") + 0.8 * x * (g == "B") + rnorm(n)
model <- lm(y ~ x * g)

try_show(lm_latex(model, format = "bracket"))
