# CASE: se_08_err_nothing_to_slide
# TYPE: console
# FUNC: slice_explore
# EXPECT: A clean error: the model's only predictor is on the x-axis, so
#         sliders = TRUE has nothing to slide. The hint explains sliders
#         drive predictors the plot does not show.

source("testing/_setup.R")

model <- lm(mpg ~ disp, data = mtcars)
try_show(slice_explore(model))
