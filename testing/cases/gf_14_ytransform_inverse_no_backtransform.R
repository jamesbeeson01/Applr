# CASE: gf_14_ytransform_inverse_no_backtransform
# TYPE: visual
# FUNC: geom_fit
# EXPECT: Model 1/y ~ x with back_transform = FALSE, plotted with the
#         TRANSFORMED response (1/y) on the y-axis: a STRAIGHT fitted line on
#         the transformed scale.

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
y <- 1/x
model <- lm(1/y ~ x)

ggplot(data.frame(x, y_trans = 1/y), aes(x, y_trans)) +
  geom_point() +
  geom_fit(model, back_transform = FALSE)
