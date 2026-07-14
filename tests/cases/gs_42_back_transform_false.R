# CASE: gs_42_back_transform_false
# TYPE: visual
# FUNC: geom_slice
# EXPECT: Model 1/y ~ x with back_transform = FALSE, plotted with the
#         TRANSFORMED response precomputed as y_trans = 1/y on the y-axis.
#         Predictions stay in 1/y space, matching the axis: ONE STRAIGHT
#         line of slope ~1 through the points. A hyperbolic curve means the
#         opt-out was ignored and it back-transformed anyway.

source("tests/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, 1, 10)  # positive x only to avoid 1/0
y <- 1/x + rnorm(n, sd = 0.05)
model <- lm(1/y ~ x)

p <- ggplot(data.frame(x, y_trans = 1/y), aes(x, y_trans)) +
  geom_point(color = "steelblue") +
  geom_slice(model, back_transform = FALSE) +
  labs(title = "gs_42: back_transform = FALSE on the transformed axis",
       subtitle = "EXPECT: Straight line, slope ~1. Hyperbolic curve = FAIL.")
p
