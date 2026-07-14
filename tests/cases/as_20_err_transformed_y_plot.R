# CASE: as_20_err_transformed_y_plot
# TYPE: console
# FUNC: add_slice_2d
# EXPECT: Scatter plot with a line that doesn't represent the model. 
#         This test should correctly produce bad output, showing the limits 
#         of the function due to base R's painter sytem for drawing plots. 
#         The plot shows the TRANSFORMED response (log(y)) but add_slice_2d
#         back-transforms its predictions — the line will not match the
#         points. Ideally a warning; currently silent (review the plot in
#         the report).

source("tests/_setup.R")
set.seed(123)

n <- 50
x_pos <- runif(n, 0, 10)
y <- exp(x_pos)
model <- lm(log(y) ~ x_pos)

plot(log(y) ~ x_pos)
try_show(add_slice_2d(model))
