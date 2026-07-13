# CASE: s2_23_interval_confidence
# TYPE: visual
# FUNC: slice_2d
# EXPECT: mtcars mpg ~ disp + hp sliced over disp with hp held at 110: the
#         usual scatter and slice line, plus a narrow shaded 95% confidence
#         band hugging the line. Silent: x_axis and hp are both specified.

source("tests/_setup.R")

model <- lm(mpg ~ disp + hp, data = mtcars)
slice_2d(model, x_axis = "disp", hp = 110, interval = "confidence")
