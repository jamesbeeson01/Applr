# CASE: se_10_err_unknown_variable
# TYPE: console
# FUNC: slice_explore
# EXPECT: A clean error: qsec is not a predictor in the model. The hint
#         lists the model's actual predictors.

source("testing/_setup.R")

model <- lm(mpg ~ disp + hp, data = mtcars)
try_show(slice_explore(model, sliders = qsec))
