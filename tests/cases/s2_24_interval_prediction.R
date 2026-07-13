# CASE: s2_24_interval_prediction
# TYPE: visual
# FUNC: slice_2d
# EXPECT: mtcars mpg ~ disp + hp sliced over disp with hp held at 110, drawn
#         in firebrick with a wide translucent firebrick 95% prediction band
#         that covers most of the points. The y-axis extends to fit the band.
#         Silent: x_axis and hp are both specified.

source("testing/_setup.R")

model <- lm(mpg ~ disp + hp, data = mtcars)
slice_2d(model, x_axis = "disp", hp = 110, interval = "prediction", col = "firebrick")
