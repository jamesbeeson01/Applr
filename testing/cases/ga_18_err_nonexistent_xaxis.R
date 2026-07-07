# CASE: ga_18_err_nonexistent_xaxis
# TYPE: console
# FUNC: geom_add_slice_2d
# EXPECT: A clear error naming the missing variable:
#         "xaxis variable 'nonexistent_var' not found in the model."

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
x_pos <- runif(n, 0, 10)
y <- x + x_pos
model <- lm(y ~ x + x_pos)

try_show(ggplot(data.frame(x, y), aes(x, y)) +
           geom_point() +
           geom_add_slice_2d(model, xaxis = "nonexistent_var"))
