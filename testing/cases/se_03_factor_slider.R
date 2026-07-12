# CASE: se_03_factor_slider
# TYPE: widget
# FUNC: slice_explore
# EXPECT: Two sliders: a continuous one for hp, and a THREE-step one for the
#         factor gear_f ("3", "4", "5") starting at "3" (the most common
#         gear). Stepping gear_f shifts the line by that gear's coefficient;
#         hp drags smoothly. Console: one Sliders message (hp at its mean
#         146.7, gear_f at "3").

source("testing/_setup.R")

cars2 <- transform(mtcars, gear_f = factor(gear))
model <- lm(mpg ~ disp + hp + gear_f, data = cars2)

slice_explore(model)
