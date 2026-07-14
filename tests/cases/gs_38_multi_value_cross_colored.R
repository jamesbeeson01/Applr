# CASE: gs_38_multi_value_cross_colored
# TYPE: visual
# FUNC: geom_slice
# EXPECT: Six parallel lines of slope ~1, one per (x2, x3) combination,
#         offset by 3*x2 + 3*x3. Lines are distinguished by color (x2) 
#         and linetype (x3).

source("tests/_setup.R")
set.seed(123)

n <- 60
x <- runif(n, -10, 10)
x2 <- sample(c(0, 2, 4), n, replace = TRUE)
x3 <- sample(c(0, 1), n, replace = TRUE)
y <- x + 3 * x2 + 3 * x3 + rnorm(n)
dat <- data.frame(x, x2, x3, y)
model <- lm(y ~ x + x2 + x3, data = dat)

ggplot(dat, aes(x, y, color = factor(x2), linetype = factor(x3))) +
  geom_point() +
  geom_slice(model)