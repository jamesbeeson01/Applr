# CASE: gs_41_back_transform_string
# TYPE: visual
# FUNC: geom_slice
# EXPECT: Same data and model as gs_09 (log(y) ~ x_pos, original y scale),
#         but with the NAMED-STRING form back_transform = "log" (meaning the
#         response was log-transformed, so predictions are exp()'d) instead
#         of auto-detection. The fitted line must be the same upward
#         exponential curve as gs_09. A straight line = FAIL.

source("testing/_setup.R")
set.seed(123)

n <- 50
x_pos <- runif(n, 0, 10)
y <- exp(x_pos) * exp(rnorm(n, sd = 0.2))  # y = exp(x_pos + noise)
model <- lm(log(y) ~ x_pos)

p <- ggplot(data.frame(x_pos, y), aes(x_pos, y)) +
  geom_point(color = "steelblue") +
  geom_slice(model, back_transform = "log") +
  labs(title = "gs_41: Named-string back_transform = \"log\"",
       subtitle = "EXPECT: Exponential curve, same as gs_09. Straight line = FAIL.")
p
