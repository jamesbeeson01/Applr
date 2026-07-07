# CASE: gf_20_mtcars_prediction
# TYPE: visual
# FUNC: geom_fit
# EXPECT: Same model as gf_19 but interval = "prediction": the same line with
#         a much WIDER ribbon (prediction interval covers individual points).

source("testing/_setup.R")

model <- lm(log(mpg) ~ disp, mtcars)

ggplot(mtcars, aes(disp, mpg)) +
  geom_point() +
  geom_fit(model, interval = "prediction")
