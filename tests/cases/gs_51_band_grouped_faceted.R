# CASE: gs_51_band_grouped_faceted
# TYPE: visual
# SIZE: 10x5
# FUNC: geom_slice
# EXPECT: mpg (displ vs hwy) colored by drv and faceted by year, with ONE
#         geom_slice call drawing a projection band per drive type in each
#         facet: edge lines at cyl = 4 and cyl = 8 in that group's natural
#         color, a translucent ribbon of the same color between them. Each
#         group's band spans only its own group's displ range within its
#         facet. This mirrors the house-price example plot (bands per color
#         group across facets).

source("testing/_setup.R")

model <- lm(hwy ~ displ * drv + cyl, data = mpg)

ggplot(mpg, aes(displ, hwy, color = drv)) +
  geom_point() +
  geom_slice(model, predict_vars = list(cyl = c(4, 8)), band = TRUE) +
  facet_wrap(~year)
