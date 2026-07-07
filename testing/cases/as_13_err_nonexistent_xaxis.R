# CASE: as_13_err_nonexistent_xaxis
# TYPE: console
# FUNC: add_slice_2d
# EXPECT: A clear error naming the missing variable:
#         "xaxis variable 'nonexistent_var' not found in the model."

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
x_pos <- runif(n, 0, 10)
y <- x + x_pos
model <- lm(y ~ x + x_pos)

plot(x, y, main = "scaffold plot")
try_show(add_slice_2d(model, xaxis = "nonexistent_var"))
