# CASE: gs_47_real_data_interaction_grouped
# TYPE: visual
# FUNC: geom_slice
# EXPECT: mpg dataset (displ vs hwy, colored by drv) with ONE geom_slice call
#         drawing three quadratic curves, one per drive type in that group's
#         natural color (model hwy ~ displ + I(displ^2) + displ:drv). Each
#         curve should follow its own group's points and span only its own
#         group's displ range.

source("testing/_setup.R")

model <- lm(hwy ~ displ + I(displ^2) + displ:drv, data = mpg)

ggplot(mpg, aes(displ, hwy, color = drv)) +
  geom_point() +
  geom_slice(model)
