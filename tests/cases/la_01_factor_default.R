# CASE: la_01_factor_default
# TYPE: console
# FUNC: lm_latex
# EXPECT: display-math LaTeX $$\underbrace{\hat{Y_i}}_{\text{Pred. y}} = 2.12 + 0.465\underbrace{X_{1i}}_{\text{x}} + 4\underbrace{X_{2i}}_{\text{gB}} - 3.19\underbrace{X_{3i}}_{\text{gC}} + 0.771\underbrace{X_{4i}}_{\text{x:gB}} + 0.046\underbrace{X_{5i}}_{\text{x:gC}}$$ with underbrace labels; factor terms
#         shown as dummy coefficient names (gB, gC, x:gB, x:gC) — the default
#         (clearer unspecified) keeps design-matrix names.

source("tests/_setup.R")
set.seed(123)

n <- 60
x <- runif(n, -10, 10)
g <- factor(sample(c("A", "B", "C"), n, replace = TRUE))
y <- 2 + 0.5 * x + 4 * (g == "B") - 3 * (g == "C") + 0.8 * x * (g == "B") + rnorm(n)
model <- lm(y ~ x * g)

try_show(lm_latex(model))
