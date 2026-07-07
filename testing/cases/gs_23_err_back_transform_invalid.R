# CASE: gs_23_err_back_transform_invalid
# TYPE: console
# FUNC: geom_slice
# EXPECT: back_transform must be a boolean or one-argument function. A list
#         should produce a clear warning or error saying so.

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
y <- 1/x
model <- lm(1/y ~ x)

try_show(ggplot(data.frame(x, y), aes(x, y)) +
           geom_point() +
           geom_slice(model, back_transform = list(a = 1)))
