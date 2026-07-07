# CASE: gf_11_ytransform_inverse
# TYPE: visual
# FUNC: geom_fit
# EXPECT: Model 1/y ~ x, plotted on the ORIGINAL y scale, default (auto)
#         back-transform: hyperbolic fitted curve. Straight line = FAIL.

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
y <- 1/x
model <- lm(1/y ~ x)

ggplot(data.frame(x, y), aes(x, y)) +
  geom_point() +
  geom_fit(model)
