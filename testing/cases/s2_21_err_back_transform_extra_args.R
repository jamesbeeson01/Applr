# CASE: s2_21_err_back_transform_extra_args
# TYPE: console
# FUNC: slice_2d
# EXPECT: A back_transform function of 2+ required arguments errors up front
#         with a clear message ("must take exactly one argument").

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
y <- 1/x
model <- lm(1/y ~ x)

try_show(slice_2d(model, back_transform = function(x, y) 1/x))
