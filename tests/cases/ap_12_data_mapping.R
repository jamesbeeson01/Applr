# CASE: ap_12_data_mapping
# TYPE: visual
# FUNC: autoplot
# EXPECT: autoplot(model, data = ..., mapping = aes(x = ..., color = ...))
#         passes data and mapping to ggplot(): the scatter comes from the
#         supplied data frame (mtcars plus a derived cyl_f column), points
#         are colored by cyl_f with a legend, and the user's aes(x = hp)
#         overrides the default disp x-axis, so the slice line runs over hp.
#         geom_slice inherits the color aesthetic, so the line is drawn per
#         cyl_f group over that group's hp range — the colored segments join
#         into one continuous model line (cyl_f is not in the model).
#         An imputation message for the now-invisible disp is expected.

source("testing/_setup.R")

model <- lm(mpg ~ disp + hp, data = mtcars)

cars2 <- transform(mtcars, cyl_f = factor(cyl))

p <- autoplot(model,
              data = cars2,
              mapping = aes(x = hp, color = cyl_f)) +
  labs(title = "ap_12: autoplot(lm) with data= and mapping=",
       subtitle = "EXPECT: hp x-axis, cyl-colored scatter, colored segments joining into one model line")
p
