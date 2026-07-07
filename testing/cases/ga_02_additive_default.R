# CASE: ga_02_additive_default
# TYPE: visual
# FUNC: geom_add_slice_2d
# EXPECT: Scatter of x vs y (y ~ x + x_pos) with one straight slice line,
#         x_pos held at its default (mean ~4.8, with a console message).

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
x_pos <- runif(n, 0, 10)
y <- x + x_pos
model <- lm(y ~ x + x_pos)

ggplot(data.frame(x, y), aes(x, y)) +
  geom_point() +
  geom_add_slice_2d(model)
