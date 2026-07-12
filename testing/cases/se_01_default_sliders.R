# CASE: se_01_default_sliders
# TYPE: widget
# FUNC: slice_explore
# EXPECT: An interactive plotly widget: mtcars scatter (disp vs mpg) with one
#         skyblue slice line, and TWO sliders below the plot labeled
#         "hp = 146.7" and "wt = 3.217" (the variables' means — the initial
#         view matches the static autoplot). Dragging the wt slider left
#         (lighter cars) moves the line UP; dragging hp left also moves it
#         up. The motion is smooth/continuous, axes do not rescale, and the
#         title shows the fitted equation. Console: one Sliders message.

source("testing/_setup.R")

model <- lm(mpg ~ disp + hp + wt, data = mtcars)

slice_explore(model)
