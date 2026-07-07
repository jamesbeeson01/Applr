# CASE: gf_15_ytransform_sqrt
# TYPE: visual
# FUNC: geom_fit
# EXPECT: Model sqrt(y) ~ x_pos (y = x_pos^2), plotted on the ORIGINAL y
#         scale. Back-transformed upward parabola. Straight line = FAIL.

source("testing/_setup.R")
set.seed(123)

n <- 50
x_pos <- runif(n, 0, 10)
y <- x_pos^2
model <- lm(sqrt(y) ~ x_pos)

ggplot(data.frame(x_pos, y), aes(x_pos, y)) +
  geom_point() +
  geom_fit(model)
