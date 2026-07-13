# CASE: gs_09_ytransform_log
# TYPE: visual
# FUNC: geom_slice
# EXPECT: Scatter of x_pos vs y on the ORIGINAL (untransformed) y scale.
#         Model is log(y) ~ x_pos, so y = exp(x_pos) approximately.
#         geom_slice should back-transform: the fitted line must be exponential-shaped
#         (curves upward), NOT a straight line.
#         If the line is straight, back-transformation failed.
#         Console message: predictions of log(y) back-transformed to the
#         y axis.

source("testing/_setup.R")
set.seed(123)

n <- 50
x_pos <- runif(n, 0, 10)
y <- exp(x_pos) * exp(rnorm(n, sd = 0.2))  # y = exp(x_pos + noise)
model <- lm(log(y) ~ x_pos)

p <- ggplot(data.frame(x_pos, y), aes(x_pos, y)) +
  geom_point(color = "steelblue") +
  geom_slice(model) +
  labs(title = "gs_09: Y-transform log(y) ~ x_pos",
       subtitle = "EXPECT: Exponential curve (back-transformed). Straight line = FAIL.")
p
