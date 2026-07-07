# CASE: s2_20_err_back_transform_invalid
# TYPE: console
# FUNC: slice_2d
# EXPECT: back_transform must be a boolean or one-argument function. A string
#         should produce a clear warning and fall back to inferring the
#         transformation from the model.

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
y <- 1/x
model <- lm(1/y ~ x)

try_show(slice_2d(model, back_transform = "not_valid"))
