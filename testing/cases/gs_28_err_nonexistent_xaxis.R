# CASE: gs_28_err_nonexistent_xaxis
# TYPE: console
# FUNC: geom_slice
# EXPECT: A clear error or warning naming the unknown variable. Currently
#         geom_slice SILENTLY IGNORES the xaxis argument ("Ignoring unknown
#         parameters: `xaxis`") and draws the default slice — if xaxis is not
#         a supported parameter it should say so explicitly.

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
x_pos <- runif(n, 0, 10)
y <- x + x_pos
model <- lm(y ~ x + x_pos)

try_show(ggplot(data.frame(x, y), aes(x, y)) +
           geom_point() +
           geom_slice(model, xaxis = "nonexistent_var"))
