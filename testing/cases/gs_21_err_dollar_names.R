# CASE: gs_21_err_dollar_names
# TYPE: console
# FUNC: geom_slice
# EXPECT: A model fit as lm(df$y ~ df$x): either work or fail with a clear
#         message about "$" in variable names. Currently imputes both
#         "df_with_dollar$y" and "df_with_dollar$x" as held variables (with
#         messages) and warns about newdata row counts — review.

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
y <- x
df_with_dollar <- data.frame(y = y, x = x)
model <- lm(df_with_dollar$y ~ df_with_dollar$x)

try_show(ggplot(data.frame(x, y), aes(x, y)) +
           geom_point() +
           geom_slice(model))
