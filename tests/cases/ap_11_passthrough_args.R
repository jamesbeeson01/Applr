# CASE: ap_11_passthrough_args
# TYPE: console
# FUNC: autoplot
# EXPECT: No output at all. autoplot.lm() forwards ... to geom_slice(), so
#         geom_slice options passed to autoplot (here interval =
#         "confidence") just work — the plot renders with a ribbon and no
#         errors, warnings, or messages.

source("testing/_setup.R")

model <- lm(mpg ~ disp, data = mtcars)

try_show(autoplot(model, interval = "confidence"))
