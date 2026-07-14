# CASE: s2_25_err_stale_data
# TYPE: console
# FUNC: slice_2d
# EXPECT: The data frame is mutated after the model is fitted, so the scatter
#         slice_2d() would draw is not the data the model describes. A clear
#         error saying the plotted data is not the data `model` was fitted to,
#         with a refit hint.

source("tests/_setup.R")
set.seed(123)

n <- 50
df <- data.frame(x = runif(n, -10, 10))
df$y <- 2 * df$x + rnorm(n)
model <- lm(y ~ x, data = df)

# Mutate the data after fitting: the model no longer describes it
df$y <- df$y * 2

try_show(slice_2d(model, x_axis = "x"))
