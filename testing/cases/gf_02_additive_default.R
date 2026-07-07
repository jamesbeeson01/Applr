# CASE: gf_02_additive_default
# TYPE: visual
# FUNC: geom_fit
# EXPECT: Scatter of x vs y (y ~ x + x_pos) with a fitted line at default held
#         values.
#         KNOWN ISSUE: currently errors "variable lengths differ (found for
#         'x_pos')" — geom_fit with no new_data falls back to model-env
#         variables of length n instead of imputing held predictors.

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
x_pos <- runif(n, 0, 10)
y <- x + x_pos
model <- lm(y ~ x + x_pos)

ggplot(data.frame(x, y), aes(x, y)) +
  geom_point() +
  geom_fit(model)
