# CASE: dw_15_err_dollar_names
# TYPE: console
# FUNC: drawit
# EXPECT: A model fit as lm(df$y ~ df$x): a clear error about "$" in variable
#         names. Currently fails with "argument \"xaxis\" is missing, with no
#         default" since no xaxis was given.

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
y <- x
df_with_dollar <- data.frame(y = y, x = x)
model <- lm(df_with_dollar$y ~ df_with_dollar$x)

plot(x, y, main = "scaffold plot")
try_show(drawit(model))
