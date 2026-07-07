# CASE: ap_11_err_unused_args
# TYPE: console
# FUNC: autoplot
# EXPECT: A student will naturally try passing geom_slice options through
#         autoplot. autoplot.lm() should eventually forward ... to
#         geom_slice(); until then this documents the current base-R
#         "unused argument" error (the autoplot generic's contract includes
#         ..., so the method signature is the gap).

source("testing/_setup.R")

model <- lm(mpg ~ disp, data = mtcars)

try_show(autoplot(model, interval = "confidence"))
