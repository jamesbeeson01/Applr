# CASE: dw_14_err_nonexistent_xaxis
# TYPE: console
# FUNC: drawit
# EXPECT: A clear error naming the missing variable. Currently emits
#         "value not specified" warnings for EVERY model variable instead of
#         rejecting the unknown xaxis.

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
x_pos <- runif(n, 0, 10)
y <- x + x_pos
model <- lm(y ~ x + x_pos)

plot(x, y, main = "scaffold plot")
try_show(drawit(model, xaxis = "nonexistent_var"))
