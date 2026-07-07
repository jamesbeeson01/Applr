# CASE: gs_36_multi_value_crossed
# TYPE: visual
# FUNC: geom_slice
# EXPECT: KNOWN ISSUE (unimplemented feature, dev_todo.Rmd: "Allow passing a
#         range of values for a slice ... ie x2=c(1,2,3),x3=c(1,4) plots 6
#         lines"). Six parallel lines of slope ~1, one per (x2, x3)
#         combination, offset by 3*x2 + 0.7*x3 (lowest: x2=1,x3=1; highest:
#         x2=3,x3=4). The reference distinguishes them by color (x2) and
#         linetype (x3) only to tell them apart — the feature's own styling
#         is not designed yet. Currently FAILs at construction: predict_vars
#         rejects vectors with "must be a single value".

source("testing/_setup.R")
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
