# CASE: ga_16_mtcars_log
# TYPE: visual
# FUNC: geom_add_slice_2d
# EXPECT: mtcars disp vs mpg, model log(mpg) ~ disp: a downward-curving
#         back-transformed slice line.

source("testing/_setup.R")

model <- lm(log(mpg) ~ disp, mtcars)

ggplot(mtcars, aes(disp, mpg)) +
  geom_point() +
  geom_add_slice_2d(model)
