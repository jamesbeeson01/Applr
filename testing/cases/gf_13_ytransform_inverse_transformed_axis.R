# CASE: gf_13_ytransform_inverse_transformed_axis
# TYPE: visual
# FUNC: geom_fit
# EXPECT: Model 1/y ~ x, plotted with the TRANSFORMED response (1/y) on the
#         y-axis. geom_fit should notice the axis matches the model response
#         and draw a STRAIGHT fitted line.

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
y <- 1/x
model <- lm(1/y ~ x)

ggplot(data.frame(x, y), aes(x, 1/y)) +
  geom_point() +
  geom_fit(model)
