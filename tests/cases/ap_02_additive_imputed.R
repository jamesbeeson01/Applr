# CASE: ap_02_additive_imputed
# TYPE: visual
# FUNC: autoplot
# EXPECT: autoplot picks the model's FIRST predictor (disp) for the x-axis.
#         mtcars scatter (disp vs mpg) with one straight downward line and
#         its default confidence ribbon — hp is invisible, so geom_slice
#         imputes it at its mean (~147, console message). Same slice as
#         gs_12's reference, plus the ribbon.

source("tests/_setup.R")

model <- lm(mpg ~ disp + hp, data = mtcars)

p <- autoplot(model, summary = FALSE) +
  labs(title = "ap_02: autoplot(lm), additive (mpg ~ disp + hp)",
       subtitle = "EXPECT: x-axis = disp (first predictor); hp imputed at mean")
p
