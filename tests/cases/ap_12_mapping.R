# CASE: ap_12_mapping
# TYPE: visual
# FUNC: autoplot
# EXPECT: scatterplot with three lines of different colors, hp on x axis.
#         autoplot(model, mapping = aes(x = ..., color = ...)) passes mapping
#         to ggplot(): the user's aes(x = hp) overrides the default disp
#         x-axis, so the slice line runs over hp, and points are colored by
#         factor(cyl) with a legend. geom_slice inherits the color aesthetic,
#         so the line is drawn per cyl group over that group's hp range, each
#         with its own default confidence ribbon in the group's colour. cyl
#         is a model variable, so grouping by it splits the one model into a
#         line per cyl level. disp is now invisible on the plot, so an
#         imputation message for it is expected.

source("tests/_setup.R")

model <- lm(mpg ~ disp + hp + factor(cyl), data = mtcars)

p <- autoplot(model, aes(x = hp, color = factor(cyl)), summary = FALSE) +
  labs(title = "ap_12: autoplot(lm) with mapping=",
       subtitle = "EXPECT: hp x-axis, cyl-colored scatter, one slice line per cyl group")
p
