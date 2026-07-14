# CASE: as_15_err_dollar_names
# TYPE: console
# FUNC: add_slice_2d
# EXPECT: A model fit as lm(df$y ~ df$x): a clear error naming the offending
#         variable, with a refit hint.

source("tests/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
y <- x
df_with_dollar <- data.frame(y = y, x = x)
model <- lm(df_with_dollar$y ~ df_with_dollar$x)

plot(x, y, main = "scaffold plot")
try_show(add_slice_2d(model))
