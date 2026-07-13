# CASE: s2_22_deprecated_xaxis_alias
# TYPE: console
# FUNC: slice_2d
# EXPECT: The old `xaxis` argument name still works but warns that it is
#         deprecated in favor of `x_axis`. The plot is drawn as if
#         `x_axis = "x_pos"` had been given (no "not specified" message).

source("tests/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
x_pos <- runif(n, 0, 10)
y <- x + x_pos
model <- lm(y ~ x + x_pos)

try_show(slice_2d(model, xaxis = "x_pos"))
