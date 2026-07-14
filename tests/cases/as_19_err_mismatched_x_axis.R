# CASE: as_19_err_mismatched_x_axis
# TYPE: console
# FUNC: add_slice_2d
# EXPECT: Scatter plot with a line that doesn't represent the model. 
#         This test should correctly produce bad output, showing the limits 
#         of the function due to base R's painter sytem for drawing plots. 
#         The slice is computed over the range of "x" while the plot shows
#         x_pos — the line lands in the wrong region. Ideally a warning;
#         currently silent (review the plot in the report).

source("tests/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
x_pos <- runif(n, 0, 10)
y <- x * x_pos
model <- lm(y ~ I(x * x_pos))

plot(x_pos, y, main = "Multiplicative data, x_axis = x",
     xlab = "x_pos", ylab = "y", pch = 19, col = "steelblue")
try_show(add_slice_2d(model, x_axis = "x"))
