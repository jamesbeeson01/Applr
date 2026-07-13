# CASE: gs_32_err_back_transform_extra_args
# TYPE: console
# FUNC: geom_slice
# EXPECT: A back_transform function of 2+ arguments should produce a clear
#         error or warning — not silently misbehave.

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
y <- 1/x
model <- lm(1/y ~ x)

try_show(ggplot(data.frame(x, y), aes(x, y)) +
           geom_point() +
           geom_slice(model, back_transform = function(x, extra_arg) 1/x))
