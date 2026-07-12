# CASE: se_05_interval_ribbon
# TYPE: widget
# FUNC: slice_explore
# EXPECT: A slice line WITH a translucent confidence ribbon, like
#         geom_slice(interval = "confidence"). One slider (hp); dragging it
#         moves the line AND its ribbon together, the ribbon staying narrow
#         near the data and widening at extreme hp values. wt is not slid:
#         it is held by predict_vars at 3, so no imputation message.
#         Console: one Sliders message for hp only.

source("testing/_setup.R")

model <- lm(mpg ~ disp + hp + wt, data = mtcars)

slice_explore(model, sliders = hp, predict_vars = list(wt = 3),
              interval = "confidence")
