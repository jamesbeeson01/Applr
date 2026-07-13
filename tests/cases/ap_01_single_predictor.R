# CASE: ap_01_single_predictor
# TYPE: visual
# FUNC: autoplot
# EXPECT: Complete plot built by autoplot(model) alone: mtcars scatter
#         (disp on x, mpg on y), one straight downward-sloping slice line
#         through the point cloud, theme_lc styling.
#         No errors, warnings, or imputation messages.

source("tests/_setup.R")

model <- lm(mpg ~ disp, data = mtcars)

p <- autoplot(model) +
  labs(title = "ap_01: autoplot(lm), single predictor (mpg ~ disp)",
       subtitle = "EXPECT: One straight downward line through the point cloud")
p
