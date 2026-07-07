# CASE: gf_12_ytransform_inverse_fn
# TYPE: visual
# FUNC: geom_fit
# EXPECT: Model 1/y ~ x with an EXPLICIT back_transform = \(x) 1/x. Same
#         hyperbolic curve as gf_11 (which infers it automatically).

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
y <- 1/x
model <- lm(1/y ~ x)

ggplot(data.frame(x, y), aes(x, y)) +
  geom_point() +
  geom_fit(model, back_transform = \(x) 1/x)
