# CASE: s2_16_err_nonexistent_x_axis
# TYPE: console
# FUNC: slice_2d
# EXPECT: A clear error naming the missing variable:
#         '`x_axis` variable "nonexistent_var" not found in the model.'
#         with a hint listing the model's predictors.

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
x_pos <- runif(n, 0, 10)
y <- x + x_pos
model <- lm(y ~ x + x_pos)

try_show(slice_2d(model, x_axis = "nonexistent_var"))
