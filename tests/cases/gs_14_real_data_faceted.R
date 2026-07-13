# CASE: gs_14_real_data_faceted
# TYPE: visual
# FUNC: geom_slice
# SIZE: 10x4
# EXPECT: Three facet panels for cyl = 4, 6, 8 (mtcars).
#         Model is mpg ~ disp + hp + cyl.
#         Each panel shows a steelblue downward-sloping line at hp=110.
#         The lines must be positioned correctly for each cylinder level:
#         cyl=4 panel at higher mpg, cyl=6 in the middle, cyl=8 at lower mpg.
#         Lines should NOT be identical across panels (cyl matters).
#         No errors.

source("testing/_setup.R")

model <- lm(mpg ~ disp + hp + cyl, data = mtcars)

p <- ggplot(mtcars, aes(disp, mpg)) +
  geom_point() +
  facet_wrap(~cyl) +
  geom_slice(model = model, predict_vars = list(hp = 110),
             color = "steelblue", linewidth = 1) +
  labs(title = "gs_14: Real data — mpg ~ disp + hp + cyl, facet_wrap(~cyl), hp=110",
       subtitle = "EXPECT: Three panels, each with correctly-positioned steelblue line")
p
