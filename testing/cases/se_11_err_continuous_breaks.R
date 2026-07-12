# CASE: se_11_err_continuous_breaks
# TYPE: console
# FUNC: slice_explore
# EXPECT: A clean error explaining slider_breaks = "continuous" is not
#         needed — sliders are continuous by default — with a hint showing
#         how to give fixed break values instead.

source("testing/_setup.R")

model <- lm(mpg ~ disp + hp, data = mtcars)
try_show(slice_explore(model, sliders = hp, slider_breaks = "continuous"))
