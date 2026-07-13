# CASE: sb_11_warn_multiple_models
# TYPE: console
# FUNC: geom_slice_subtitle
# EXPECT: A clear warning that the plot's geom_slice() layers use two
#         different models — a subtitle can describe ONE model, so none is
#         added. The warning names the models and hints to use one model per
#         plot. Mirrors gt_12_warn_multiple_models.

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
    geom_slice_subtitle()
)
