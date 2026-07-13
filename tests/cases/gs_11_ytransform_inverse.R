# CASE: gs_11_ytransform_inverse
# TYPE: visual
# FUNC: geom_slice
# EXPECT: Scatter of x vs y on ORIGINAL y scale (y = 1/x, so hyperbolic shape).
#         Model is 1/y ~ x, so geom_slice must back-transform via 1/fitted.
#         The fitted line should be hyperbola-shaped: large y near x=0, approaching 0
#         as x grows large.
#         A straight line on this plot means back-transformation failed.
#         Console message: predictions of 1/y back-transformed to the y axis.

source("tests/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, 1, 10)  # positive x only to avoid 1/0
y <- 1/x + rnorm(n, sd = 0.05)
model <- lm(1/y ~ x)

p <- ggplot(data.frame(x, y), aes(x, y)) +
  geom_point(color = "steelblue") +
  geom_slice(model) +
  labs(title = "gs_11: Y-transform 1/y ~ x",
       subtitle = "EXPECT: Hyperbolic curve, decreasing. Straight line = FAIL.")
p
