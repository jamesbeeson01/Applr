# CASE: as_17_err_no_plot_open
# TYPE: console
# FUNC: add_slice_2d
# EXPECT: Calling add_slice_2d with NO plot open should error — currently the
#         raw base-graphics "plot.new has not been called yet"; a friendlier
#         message would be better.

source("tests/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
y <- x
model <- lm(y ~ x)

try_show(add_slice_2d(model))
