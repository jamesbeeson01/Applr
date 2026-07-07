# CASE: s2_14_mtcars_log
# TYPE: visual
# FUNC: slice_2d
# EXPECT: Model log(mpg) ~ disp on mtcars. Scatter of disp vs mpg with a
#         downward-curving back-transformed slice line.

source("testing/_setup.R")

model <- lm(log(mpg) ~ disp, mtcars)

slice_2d(model)
