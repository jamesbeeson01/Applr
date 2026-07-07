# CASE: gf_07_multiplicative_new_data
# TYPE: visual
# FUNC: geom_fit
# EXPECT: Model y ~ I(x*x_pos), plotted with x alone on the x-axis and
#         new_data = data.frame(x_pos = 4.8): the fitted line for that fixed
#         x_pos (slope ~4.8 through the cloud).

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
x_pos <- runif(n, 0, 10)
y <- x * x_pos
model <- lm(y ~ I(x * x_pos))

ggplot(data.frame(x, x_pos, y), aes(x, y)) +
  geom_point() +
  geom_fit(model, new_data = data.frame(x_pos = 4.8))
