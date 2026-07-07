# CASE: gf_17_ytransform_exp
# TYPE: visual
# FUNC: geom_fit
# EXPECT: Model exp(y) ~ x_pos (y = log(x_pos)), plotted on the ORIGINAL y
#         scale. Back-transformed logarithmic curve. Straight line = FAIL.

source("testing/_setup.R")
set.seed(123)

n <- 50
x_pos <- runif(n, 0, 10)
y <- log(x_pos)
model <- lm(exp(y) ~ x_pos)

ggplot(data.frame(x_pos, y), aes(x_pos, y)) +
  geom_point() +
  geom_fit(model)
