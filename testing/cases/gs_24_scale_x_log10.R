# CASE: gs_24_scale_x_log10
# TYPE: visual
# FUNC: geom_slice
# EXPECT: Model y ~ x with the x-axis displayed through scale_x_log10().
#         Data is noise-free (y = 2*x + 10 exactly, R^2 = 1), so the slice
#         must pass exactly through every point: on the log10 axis the line
#         appears as a steepening upward curve (exponential-looking), NOT a
#         straight line. No errors.
#         KNOWN ISSUE: the stat receives log10-transformed x positions and
#         feeds them to predict() as raw data, so the line is drawn nearly
#         flat along the bottom instead of through the points.

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, 1, 100)
y <- 2 * x + 10
model <- lm(y ~ x)

p <- ggplot(data.frame(x, y), aes(x, y)) +
  geom_point(color = "steelblue") +
  geom_slice(model) +
  scale_x_log10() +
  labs(title = "gs_24: scale_x_log10() with y ~ x",
       subtitle = "EXPECT: Curve exactly through all points on the log10 x-axis")
p
