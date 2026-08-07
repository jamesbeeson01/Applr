# CASE: gs_59_band_true_grouped_color
# TYPE: visual
# FUNC: geom_slice
# EXPECT: mpg (displ vs hwy) colored by drv, model hwy ~ displ * drv + cyl.
#         Three variables, three roles: displ on the x-axis, drv on color, and
#         cyl left for band = TRUE to infer — it is the only predictor the plot
#         does not otherwise show. With no predict_vars, its range is imputed
#         from the data (4 to 8), so one message names that range.
#         Result: a projection band per drive type, each with two edge lines
#         (cyl = 4 and cyl = 8) and a translucent ribbon between them IN THAT
#         GROUP'S COLOR, spanning only its own group's displ range. Unlike
#         gs_51 there are no facets and no predict_vars — the band variable and
#         its range are both inferred (the grouped counterpart of gs_52).

source("tests/_setup.R")

model <- lm(hwy ~ displ * drv + cyl, data = mpg)

ggplot(mpg, aes(displ, hwy, color = drv)) +
  geom_point() +
  geom_slice(model, band = TRUE)
