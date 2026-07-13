# CASE: gs_12_real_data_two_predictors
# TYPE: visual
# FUNC: geom_slice
# EXPECT: mtcars scatter (disp vs mpg). Model is mpg ~ disp + hp.
#         One fitted line with hp held at its mean (~146).
#         Line should slope downward (more displacement -> less mpg) and pass
#         through the middle of the point cloud.
#         Console message: hp not specified, held at its mean (146.7).
#         No errors.

source("testing/_setup.R")

model <- lm(mpg ~ disp + hp, data = mtcars)

p <- ggplot(mtcars, aes(disp, mpg)) +
  geom_point(color = "steelblue") +
  geom_slice(model) +
  labs(title = "gs_12: Real data — mpg ~ disp + hp, default held (hp = mean)",
       subtitle = "EXPECT: One downward-sloping line through the point cloud")
p
