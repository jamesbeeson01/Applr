# CASE: se_09_err_slider_on_axis
# TYPE: console
# FUNC: slice_explore
# EXPECT: A clean error: disp is on the x-axis, so it cannot get a slider.
#         The hint names the predictors that could slide instead (hp, wt).

source("testing/_setup.R")

model <- lm(mpg ~ disp + hp + wt, data = mtcars)
try_show(slice_explore(model, sliders = disp))
