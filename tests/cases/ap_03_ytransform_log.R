# CASE: ap_03_ytransform_log
# TYPE: visual
# FUNC: autoplot
# EXPECT: autoplot's all.vars() strips the response transform, so the y-axis
#         is RAW mpg even though the model is log(mpg) ~ disp. geom_slice
#         must auto back-transform (console message): one smooth decreasing
#         exp() curve through the raw-scale point cloud, not a straight line.

source("testing/_setup.R")

model <- lm(log(mpg) ~ disp, data = mtcars)

p <- autoplot(model) +
  labs(title = "ap_03: autoplot(lm), transformed response (log(mpg) ~ disp)",
       subtitle = "EXPECT: decreasing exp curve, back-transformed to raw mpg axis")
p
