# CASE: gs_46_both_intervals
# TYPE: visual
# FUNC: geom_slice
# EXPECT: Same model and slice as gs_33/gs_34 (mpg ~ disp + hp at hp = 110),
#         with TWO geom_slice layers: confidence and prediction intervals
#         together — a NARROW ribbon nested inside a WIDE one, sharing one
#         straight downward line (see reference).

source("tests/_setup.R")

model <- lm(mpg ~ disp + hp, data = mtcars)

ggplot(mtcars, aes(disp, mpg)) +
  geom_point() +
  geom_slice(model, predict_vars = list(hp = 110), interval = "prediction") +
  geom_slice(model, predict_vars = list(hp = 110), interval = "confidence")
