# CASE: ap_13_sliders
# TYPE: widget
# FUNC: autoplot
# EXPECT: autoplot(model, sliders = cyl, slider_breaks = c(4, 6, 8)) routes
#         to slice_explore(): an interactive widget with ONE three-step
#         slider for cyl (4 / 6 / 8, starting at 6, the value nearest the
#         mean) — a bare vector is accepted for slider_breaks because there
#         is a single slider. hp has no slider and is not in predict_vars,
#         so geom_slice imputes it at its mean with its usual console
#         message; the Sliders message names cyl only.

source("testing/_setup.R")

model <- lm(mpg ~ disp + cyl + hp, data = mtcars)

autoplot(model, sliders = cyl, slider_breaks = c(4, 6, 8))
