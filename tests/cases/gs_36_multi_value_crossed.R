# CASE: gs_36_multi_value_crossed
# TYPE: visual
# FUNC: geom_slice
# EXPECT: Six parallel lines of slope ~1, one per (x2, x3) combination,
#         offset by 3*x2 + 0.7*x3 (lowest: x2=1,x3=1; highest: x2=3,x3=4).
#         geom_slice draws all six in its default color.

source("tests/_setup.R")
set.seed(123)

n <- 60
x <- runif(n, -10, 10)
x2 <- runif(n, 0, 4)
x3 <- runif(n, 0, 5)
y <- x + 3 * x2 + 0.7 * x3 + rnorm(n)
dat <- data.frame(x, x2, x3, y)
model <- lm(y ~ x + x2 + x3, data = dat)

ggplot(dat, aes(x, y)) +
  geom_point() +
  geom_slice(model, predict_vars = list(x2 = c(1, 2, 3), x3 = c(1, 4)))
