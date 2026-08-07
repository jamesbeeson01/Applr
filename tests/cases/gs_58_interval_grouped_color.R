# CASE: gs_58_interval_grouped_color
# TYPE: visual
# FUNC: geom_slice
# EXPECT: mpg dataset (displ vs hwy, colored by drv), model
#         hwy ~ displ + I(displ^2) + displ:drv, with
#         interval = "confidence": three quadratic curves in the group colors
#         AND three confidence ribbons, each ribbon FILLED IN ITS OWN GROUP'S
#         COLOR (translucent, alpha 0.4) — not a neutral skyblue. Each
#         curve/ribbon spans only its own group's displ range (see reference).
#         The legend keys match too: each key's ribbon patch is its own group's
#         color, not skyblue.

source("tests/_setup.R")

model <- lm(hwy ~ displ + I(displ^2) + displ:drv, data = mpg)

ggplot(mpg, aes(displ, hwy, color = drv)) +
  geom_point() +
  geom_slice(model, interval = "confidence")
