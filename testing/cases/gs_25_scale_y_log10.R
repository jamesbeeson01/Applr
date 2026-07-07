# CASE: gs_25_scale_y_log10
# TYPE: visual
# FUNC: geom_slice
# EXPECT: Model y ~ x with the y-axis displayed through scale_y_log10().
#         Data is noise-free (y = 3*x + 2 exactly, R^2 = 1), so the slice must
#         pass exactly through every point: on the log10 axis the line appears
#         as a rising curve that flattens to the right (log-looking), NOT a
#         straight line. No errors.

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, 0.5, 10)
y <- 3 * x + 2
model <- lm(y ~ x)

p <- ggplot(data.frame(x, y), aes(x, y)) +
  geom_point(color = "steelblue") +
  geom_slice(model) +
  scale_y_log10() +
  labs(title = "gs_25: scale_y_log10() with y ~ x",
       subtitle = "EXPECT: Curve exactly through all points on the log10 y-axis")
p
