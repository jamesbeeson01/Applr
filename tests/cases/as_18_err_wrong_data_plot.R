# CASE: as_18_err_wrong_data_plot
# TYPE: console
# FUNC: add_slice_2d
# EXPECT: Adding a slice from one model onto a plot of ENTIRELY different
#         data. Ideally a warning that the ranges don't match; currently the
#         line is drawn silently (review the plot in the report).

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
x_pos <- runif(n, 0, 10)
y_multiply <- x * x_pos
y_log <- exp(x_pos)
model_log <- lm(log(y_log) ~ x_pos)

plot(x_pos, y_multiply, main = "Multiplicative data, log-model slice",
     xlab = "x_pos", ylab = "y", pch = 19, col = "steelblue")
try_show(add_slice_2d(model_log))
