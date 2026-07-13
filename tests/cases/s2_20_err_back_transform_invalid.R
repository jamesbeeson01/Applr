# CASE: s2_20_err_back_transform_invalid
# TYPE: console
# FUNC: slice_2d
# EXPECT: An unknown back_transform name errors up front, listing the known
#         names ("log", "log10", ...) — consistent with geom_slice.

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
y <- 1/x
model <- lm(1/y ~ x)

try_show(slice_2d(model, back_transform = "not_valid"))
