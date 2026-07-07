# CASE: as_22_err_back_transform_extra_args
# TYPE: console
# FUNC: add_slice_2d
# EXPECT: A back_transform function of 2+ arguments should produce a CLEAR
#         error or warning. Currently dies with "cannot coerce type 'closure'
#         to vector of type 'character'" — unhelpful for students.

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
y <- 1/x
model <- lm(1/y ~ x)

plot(x, y, main = "scaffold plot", pch = 19, col = "steelblue")
try_show(add_slice_2d(model, back_transform = function(x, y, z) 1/x))
