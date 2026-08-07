# CASE: ap_15_auto_color_facet
# TYPE: visual
# FUNC: autoplot
# EXPECT: mtcars scatter (hp on x, mpg on y) that autoplot infers into groups:
#         the few-value predictor cyl becomes the colour (one slice line per
#         cyl level, each with its own confidence ribbon) and gear becomes
#         facet panels. Console: one "Coloured by
#         cyl" and one "Faceted by gear" message; nothing is imputed.

source("tests/_setup.R")

model <- lm(mpg ~ hp + cyl + gear, data = mtcars)

p <- autoplot(model, summary = FALSE) +
  labs(title = "ap_15: autoplot(lm) auto colour + facet",
       subtitle = "EXPECT: hp x-axis, cyl-coloured lines, gear facets")
p
