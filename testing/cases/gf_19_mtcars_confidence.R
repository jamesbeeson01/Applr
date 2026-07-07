# CASE: gf_19_mtcars_confidence
# TYPE: visual
# FUNC: geom_fit
# EXPECT: mtcars disp vs mpg, model log(mpg) ~ disp, default settings:
#         downward-curving back-transformed line with a NARROW confidence
#         ribbon.

source("testing/_setup.R")

model <- lm(log(mpg) ~ disp, mtcars)

ggplot(mtcars, aes(disp, mpg)) +
  geom_point() +
  geom_fit(model)
