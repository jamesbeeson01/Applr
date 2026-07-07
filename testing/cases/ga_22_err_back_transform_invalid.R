# CASE: ga_22_err_back_transform_invalid
# TYPE: console
# FUNC: geom_add_slice_2d
# EXPECT: back_transform must be a boolean or one-argument function. A string
#         should produce a clear warning and fall back to inferring the
#         transformation from the model.

source("testing/_setup.R")
set.seed(123)

n <- 50
x_pos <- runif(n, 0, 10)
y <- exp(x_pos)
model <- lm(log(y) ~ x_pos)

try_show(ggplot(data.frame(x_pos, y), aes(x_pos, y)) +
           geom_point() +
           geom_add_slice_2d(model, back_transform = "invalid"))
