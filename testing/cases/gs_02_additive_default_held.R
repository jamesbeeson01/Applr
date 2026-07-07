# CASE: gs_02_additive_default_held
# TYPE: visual
# FUNC: geom_slice
# EXPECT: Scatter of x vs y (additive model y ~ x + x_pos).
#         One fitted line, with x_pos auto-imputed to its mean (~5).
#         Line should sit near the center of the point cloud.
#         No errors.

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
x_pos <- runif(n, 0, 10)
y <- x + x_pos + rnorm(n)
model <- lm(y ~ x + x_pos)

p <- ggplot(data.frame(x, y), aes(x, y)) +
  geom_point(color = "steelblue") +
  geom_slice(model) +
  labs(title = "gs_02: Additive model, default held value",
       subtitle = "EXPECT: One line at x_pos = mean(x_pos) ~= 5")
p
