# CASE: gf_23_mpg_interaction
# TYPE: visual
# FUNC: geom_fit
# EXPECT: mpg dataset (displ vs hwy, colored by drv) with three geom_fit
#         curves, one per drive type via new_data: red = 4wd, green = front,
#         blue = rear. Each curve should follow its own group's points
#         (quadratic model with displ:drv interaction).

source("testing/_setup.R")

model <- lm(hwy ~ displ + I(displ^2) + displ:drv, mpg)

ggplot(mpg, aes(displ, hwy, color = drv)) +
  geom_point() +
  geom_fit(model, data.frame(drv = "4"), color = "red") +
  geom_fit(model, data.frame(drv = "f"), color = "green") +
  geom_fit(model, data.frame(drv = "r"), color = "blue") +
  scale_color_manual(values = c("red", "green", "blue"))
