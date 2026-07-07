# CASE: gf_03_additive_new_data
# TYPE: visual
# FUNC: geom_fit
# EXPECT: Scatter of x vs y (y ~ x + x_pos) with the fitted line at
#         x_pos = 0.007 via new_data — near the BOTTOM of the point cloud.

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
x_pos <- runif(n, 0, 10)
y <- x + x_pos
model <- lm(y ~ x + x_pos)

ggplot(data.frame(x, y), aes(x, y)) +
  geom_point() +
  geom_fit(model, new_data = data.frame(x_pos = 0.007))
