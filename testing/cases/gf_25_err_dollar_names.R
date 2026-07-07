# CASE: gf_25_err_dollar_names
# TYPE: console
# FUNC: geom_fit
# EXPECT: A model fit as lm(df$y ~ df$x): either work or fail with a clear
#         message about "$" in variable names. Currently fails with
#         "could not find function \"inverse\"" after an inverse-creation
#         message — an internal error leaking out.

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
y <- x
df_with_dollar <- data.frame(y = y, x = x)
model <- lm(df_with_dollar$y ~ df_with_dollar$x)

try_show(ggplot(data.frame(x, y), aes(x, y)) +
           geom_point() +
           geom_fit(model))
