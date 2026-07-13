# CASE: gs_35_multi_value_single_var
# TYPE: visual
# FUNC: geom_slice
# EXPECT: Three parallel lines of slope ~1, one per x_pos value (1, 5, 9),
#         evenly offset in y. geom_slice draws all three in its default color.

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
x_pos <- runif(n, 0, 10)
y <- x + x_pos + rnorm(n)
dat <- data.frame(x, x_pos, y)
model <- lm(y ~ x + x_pos, data = dat)

ggplot(dat, aes(x, y)) +
  geom_point() +
  geom_slice(model, predict_vars = list(x_pos = c(1, 5, 9)))
