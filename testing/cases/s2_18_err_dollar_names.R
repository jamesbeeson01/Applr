# CASE: s2_18_err_dollar_names
# TYPE: console
# FUNC: slice_2d
# EXPECT: A model fit as lm(df$y ~ df$x) has "$" in its variable names. A
#         clear error ("Cannot use lm with '$' in its variable names"), not a
#         cryptic parse failure.

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
y <- x
df_with_dollar <- data.frame(y = y, x = x)
model <- lm(df_with_dollar$y ~ df_with_dollar$x)

try_show(slice_2d(model))
