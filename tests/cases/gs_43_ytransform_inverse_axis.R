# CASE: gs_43_ytransform_inverse_axis
# TYPE: visual
# FUNC: geom_slice
# EXPECT: Model 1/y ~ x, plotted with the TRANSFORMED response mapped inline
#         on the y-axis (aes(x, 1/y)). geom_slice should notice the axis
#         expression matches the model's response and use predictions as-is:
#         ONE STRAIGHT line of slope ~1 through the points. This is the
#         decreasing-transform analog of gs_26 (which uses log).
#         A hyperbolic curve means it wrongly back-transformed.

source("tests/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, 1, 10)  # positive x only to avoid 1/0
y <- 1/x + rnorm(n, sd = 0.05)
model <- lm(1/y ~ x)

p <- ggplot(data.frame(x, y), aes(x, 1/y)) +
  geom_point(color = "steelblue") +
  geom_slice(model) +
  labs(title = "gs_43: Inline 1/y on the y-axis (1/y ~ x)",
       subtitle = "EXPECT: Straight line, slope ~1. Hyperbolic curve = FAIL.")
p
