# CASE: cp_01_default_imputed
# TYPE: visual
# FUNC: geom_slice_caption
# EXPECT: The caption twin of sb_01. One skyblue slice of y ~ x + x2 with x2
#         imputed at its mean. Called with NO parameters,
#         geom_slice_caption() fills the plot CAPTION (bottom-right,
#         right-aligned by the default theme) with TWO lines: line 1 the
#         model equation (lm_equation() style, 3 sig figs), line 2
#         "held at: x2 = <mean>" (4 sig figs). The subtitle stays empty and
#         the user's own labs(title) is untouched.

source("tests/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
x2 <- runif(n, 0, 5)
y <- x + 2 * x2 + rnorm(n)
dat <- data.frame(x, x2, y)
model <- lm(y ~ x + x2, data = dat)

p <- ggplot(dat, aes(x, y)) +
  geom_point(color = "gray60") +
  geom_slice(model) +
  geom_slice_caption() +
  labs(title = "cp_01: Default caption — equation line + held-values line")
p
