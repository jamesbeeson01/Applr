# CASE: gt_12_warn_multiple_models
# TYPE: console
# FUNC: geom_slice_text
# EXPECT: A clear warning that the plot's geom_slice() layers use two
#         different models — geom_slice_text() labels slices of ONE model,
#         so it cannot tell which lines to describe. The warning should name
#         the models (or say how many were found) and hint to label one model
#         per plot.

source("tests/_setup.R")
set.seed(123)

n <- 40
x <- runif(n, -10, 10)
x2 <- runif(n, 0, 5)
y <- x + 2 * x2 + rnorm(n)
dat <- data.frame(x, x2, y)
model_a <- lm(y ~ x, data = dat)
model_b <- lm(y ~ x + x2, data = dat)

try_show(
  ggplot(dat, aes(x, y)) +
    geom_point() +
    geom_slice(model_a) +
    geom_slice(model_b, predict_vars = list(x2 = 1)) +
    geom_slice_text()
)
