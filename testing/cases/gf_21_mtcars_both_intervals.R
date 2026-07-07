# CASE: gf_21_mtcars_both_intervals
# TYPE: visual
# FUNC: geom_fit
# EXPECT: Two geom_fit layers on one plot: confidence and prediction
#         intervals together — a narrow ribbon nested inside a wide one.

source("testing/_setup.R")

model <- lm(log(mpg) ~ disp, mtcars)

ggplot(mtcars, aes(disp, mpg)) +
  geom_point() +
  geom_fit(model) +
  geom_fit(model, interval = "prediction")
