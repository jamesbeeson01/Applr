# CASE: gs_37_err_data_mismatch
# TYPE: console
# FUNC: geom_slice
# EXPECT: A clear, student-readable error saying the plotted data is not the
#         data `model` was fitted to (raised when the layer is added to the
#         plot, before anything is drawn).

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
y <- 2 * x + rnorm(n)
fitted_data <- data.frame(x, y)
model <- lm(y ~ x, data = fitted_data)

# A different dataset that happens to share the column names.
other_data <- data.frame(x = runif(n, -10, 10), y = rnorm(n, 5, 3))

try_show(ggplot(other_data, aes(x, y)) +
           geom_point() +
           geom_slice(model))
