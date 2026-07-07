# CASE: gf_22_mtcars_no_se
# TYPE: visual
# FUNC: geom_fit
# EXPECT: Same model as gf_19 but se = FALSE: the fitted line only, no ribbon.

source("testing/_setup.R")

model <- lm(log(mpg) ~ disp, mtcars)

ggplot(mtcars, aes(disp, mpg)) +
  geom_point() +
  geom_fit(model, se = FALSE)
