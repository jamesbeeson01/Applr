# CASE: s2_14_mtcars_log
# TYPE: visual
# FUNC: slice_2d
# EXPECT: Model log(mpg) ~ disp on mtcars. Scatter of disp vs mpg with a
#         downward-curving back-transformed slice line.
#         Console message: x_axis not specified, first x variable (disp) used.

source("tests/_setup.R")

model <- lm(log(mpg) ~ disp, mtcars)

slice_2d(model)
