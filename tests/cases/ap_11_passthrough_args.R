# CASE: ap_11_passthrough_args
# TYPE: visual
# FUNC: autoplot
# EXPECT: Scatter plot with line and a WIDE prediction interval band —
#         noticeably wider than autoplot's default confidence ribbon, and
#         covering most of the point cloud. autoplot.lm() forwards its
#         geom_slice options, so interval = "prediction" overrides the
#         "confidence" default. No errors, warnings, or messages.

source("tests/_setup.R")

model <- lm(mpg ~ disp, data = mtcars)

try_show(autoplot(model, interval = "prediction", summary = FALSE))
