# CASE: gs_13_real_data_predict_vars
# TYPE: visual
# FUNC: geom_slice
# EXPECT: mtcars scatter (disp vs mpg). Model is mpg ~ disp + hp.
#         Two fitted lines:
#         Blue line = hp held at 100 (low hp -> higher mpg prediction)
#         Red line  = hp held at 250 (high hp -> lower mpg prediction)
#         Both lines slope downward. Red line sits below blue line.
#         No errors.

source("tests/_setup.R")

model <- lm(mpg ~ disp + hp, data = mtcars)

p <- ggplot(mtcars, aes(disp, mpg)) +
  geom_point(color = "gray60") +
  geom_slice(model, predict_vars = list(hp = 100), color = "steelblue", linewidth = 1) +
  geom_slice(model, predict_vars = list(hp = 250), color = "firebrick", linewidth = 1) +
  labs(title = "gs_13: Real data — two slices at hp=100 (blue) and hp=250 (red)",
       subtitle = "EXPECT: Blue line higher than red, both sloping down with disp")
p
