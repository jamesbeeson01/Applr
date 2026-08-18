# CASE: gt_16_band_edges_grouped
# TYPE: visual
# FUNC: geom_slice_text
# EXPECT: the README's projection-band example (gs_59 plus labels). displ on
#         x, drv on color, cyl inferred by band = TRUE and spanned over its
#         imputed 4-8 range. Each of the three bands gets TWO labels, one per
#         edge, in that group's color: "cyl: 4" and "cyl: 8".
#         cyl's coefficient on hwy is NEGATIVE, so the labels are FLIPPED
#         relative to gt_15 - "cyl: 4" UPPER, "cyl: 8" lower: each label
#         belongs to the edge its value produced, not to the smaller y.
#         The old "drv: <level>" label at each band's midline must not
#         reappear (drv is already in the legend).
#         Exactly ONE console message: the imputed 4-8 band range.

source("tests/_setup.R")

model <- lm(hwy ~ displ * drv + cyl, data = mpg)

p <- ggplot(mpg, aes(displ, hwy, color = drv)) +
  geom_point() +
  geom_slice(model, band = TRUE) +
  geom_slice_text() +
  labs(title = "gt_16: Band edges labeled per group",
       subtitle = "EXPECT: 'cyl: 4' (upper) and 'cyl: 8' (lower) on each band")
p
