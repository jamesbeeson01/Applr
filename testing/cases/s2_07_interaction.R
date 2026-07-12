# CASE: s2_07_interaction
# TYPE: visual
# FUNC: slice_2d
# EXPECT: Model y ~ x:x_switch. Default slice_2d plot: scatter of x vs y with
#         one slice line at the default held x_switch value (see caption).
#         Console messages: xaxis defaulting to the first x variable (x),
#         and x_switch held at its mean (~0.9).

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
x_switch <- sample(c(0, 1, 2), n, replace = TRUE)
y <- x * x_switch
model <- lm(y ~ x:x_switch)

slice_2d(model)
