# CASE: as_23_interval_confidence
# TYPE: visual
# FUNC: add_slice_2d
# EXPECT: A plain mtcars scatter of mpg vs disp, then add_slice_2d() overlays
#         a firebrick slice line (hp held at 110) with a translucent firebrick
#         95% confidence band around it. Silent: x_axis and hp are specified.

source("tests/_setup.R")

model <- lm(mpg ~ disp + hp, data = mtcars)

plot(mpg ~ disp, data = mtcars, pch = 19, col = "steelblue")
add_slice_2d(model, x_axis = "disp", hp = 110, interval = "confidence", col = "firebrick")
