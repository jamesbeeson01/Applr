# CASE: gf_18_ytransform_square
# TYPE: visual
# FUNC: geom_fit
# EXPECT: Model y^2 ~ x_pos (y = sqrt(x_pos)), plotted on the ORIGINAL y
#         scale. Back-transformed square-root curve. Straight line = FAIL.

source("testing/_setup.R")
set.seed(123)

n <- 50
x_pos <- runif(n, 0, 10)
y <- sqrt(x_pos)
model <- lm(y^2 ~ x_pos)

ggplot(data.frame(x_pos, y), aes(x_pos, y)) +
  geom_point() +
  geom_fit(model)
