# CASE: se_12_err_conflict_predict_vars
# TYPE: console
# FUNC: slice_explore
# EXPECT: A clean error: hp cannot both slide and be held by predict_vars.
#         The hint says to drop it from one of the two.

source("testing/_setup.R")

model <- lm(mpg ~ disp + hp + wt, data = mtcars)
try_show(slice_explore(model, sliders = hp, predict_vars = list(hp = 110)))
