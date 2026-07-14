# CASE: ap_11_passthrough_args
# TYPE: visual
# FUNC: autoplot
# EXPECT: Scatter plot with line and confidence interval band.
#         autoplot.lm() forwards ... to geom_slice(), so
#         geom_slice options passed to autoplot (here interval =
#         "confidence") and renders with no errors, warnings, or 
#         messages.

source("tests/_setup.R")

model <- lm(mpg ~ disp, data = mtcars)

try_show(autoplot(model, interval = "confidence"))
