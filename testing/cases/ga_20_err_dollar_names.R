# CASE: ga_20_err_dollar_names
# TYPE: console
# FUNC: geom_add_slice_2d
# EXPECT: A model fit as lm(df$y ~ df$x): a clear error
#         ("Cannot use lm with '$' in its variable names").

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
y <- x
df_with_dollar <- data.frame(y = y, x = x)
model <- lm(df_with_dollar$y ~ df_with_dollar$x)

try_show(ggplot(data.frame(x, y), aes(x, y)) +
           geom_point() +
           geom_add_slice_2d(model))
