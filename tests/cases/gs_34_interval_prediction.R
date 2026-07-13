# CASE: gs_34_interval_prediction
# TYPE: visual
# FUNC: geom_slice
# EXPECT: mtcars disp vs mpg, model mpg ~ disp + hp sliced at hp = 110: one
#         straight downward line with a WIDE prediction ribbon containing
#         most of the points (see reference).

source("tests/_setup.R")

model <- lm(mpg ~ disp + hp, data = mtcars)

ggplot(mtcars, aes(disp, mpg)) +
  geom_point() +
  geom_slice(model, predict_vars = list(hp = 110), interval = "prediction")
