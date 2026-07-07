# CASE: gf_06_multiplicative_x_axis
# TYPE: visual
# FUNC: geom_fit
# EXPECT: Model y ~ I(x*x_pos), plotted with x alone on the x-axis. Review
#         how geom_fit handles the product term with no new_data.

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
x_pos <- runif(n, 0, 10)
y <- x * x_pos
model <- lm(y ~ I(x * x_pos))

ggplot(data.frame(x, x_pos, y), aes(x, y)) +
  geom_point() +
  geom_fit(model)
