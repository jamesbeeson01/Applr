# CASE: gs_40_back_transform_fn
# TYPE: visual
# FUNC: geom_slice
# EXPECT: Same data and model as gs_11 (1/y ~ x, original y scale), but with
#         an EXPLICIT back_transform = \(z) 1/z instead of auto-detection.
#         The fitted line must be the same decreasing hyperbolic curve as
#         gs_11. A straight line means the explicit function was ignored.

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, 1, 10)  # positive x only to avoid 1/0
y <- 1/x + rnorm(n, sd = 0.05)
model <- lm(1/y ~ x)

p <- ggplot(data.frame(x, y), aes(x, y)) +
  geom_point(color = "steelblue") +
  geom_slice(model, back_transform = \(z) 1/z) +
  labs(title = "gs_40: Explicit back_transform = \\(z) 1/z",
       subtitle = "EXPECT: Hyperbolic curve, same as gs_11. Straight line = FAIL.")
p
