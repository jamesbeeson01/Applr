# CASE: gf_16_ytransform_log
# TYPE: visual
# FUNC: geom_fit
# EXPECT: Model log(y) ~ x_pos (y = exp(x_pos)), plotted on the ORIGINAL y
#         scale. Back-transformed exponential curve. Straight line = FAIL.

source("testing/_setup.R")
set.seed(123)

n <- 50
x_pos <- runif(n, 0, 10)
y <- exp(x_pos)
model <- lm(log(y) ~ x_pos)

ggplot(data.frame(x_pos, y), aes(x_pos, y)) +
  geom_point() +
  geom_fit(model)
