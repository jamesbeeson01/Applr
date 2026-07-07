# CASE: gf_04_quadratic
# TYPE: visual
# FUNC: geom_fit
# EXPECT: Model y ~ x + I(x^2). Scatter of x vs y with an upward-opening
#         parabola plus confidence ribbon (not a straight line).

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
y <- x + x^2
model <- lm(y ~ x + I(x^2))

ggplot(data.frame(x, y), aes(x, y)) +
  geom_point() +
  geom_fit(model)
