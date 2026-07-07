# CASE: ga_03_additive_predict_var
# TYPE: visual
# FUNC: geom_add_slice_2d
# EXPECT: Scatter of x vs y (y ~ x + x_pos) with the slice line at
#         x_pos = 0.007 — near the BOTTOM of the point cloud.

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
x_pos <- runif(n, 0, 10)
y <- x + x_pos
model <- lm(y ~ x + x_pos)

ggplot(data.frame(x, y), aes(x, y)) +
  geom_point() +
  geom_add_slice_2d(model, x_pos = 0.007)
