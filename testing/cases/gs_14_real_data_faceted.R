# gs_14_real_data_faceted.R  ← TARGET CASE
# EXPECT: Three facet panels for cyl = 4, 6, 8 (mtcars).
#         Model is mpg ~ disp + hp + cyl.
#         Each panel shows a steelblue downward-sloping line at hp=110.
#         The lines must be positioned correctly for each cylinder level:
#           cyl=4 panel: line at higher mpg values
#           cyl=6 panel: line in middle mpg range
#           cyl=8 panel: line at lower mpg values
#         Lines should NOT be identical across panels (cyl matters).
#         No errors.

devtools::load_all(".")
suppressPackageStartupMessages(library(ggplot2))

model <- lm(mpg ~ disp + hp + cyl, data = mtcars)

p <- ggplot(mtcars, aes(disp, mpg)) +
  geom_point() +
  facet_wrap(~cyl) +
  geom_slice(model = model, predict_vars = list(hp = 110),
             color = "steelblue", linewidth = 1) +
  labs(title = "gs_14: Real data — mpg ~ disp + hp + cyl, facet_wrap(~cyl), hp=110",
       subtitle = "EXPECT: Three panels, each with correctly-positioned steelblue line")

dir.create("testing/output", showWarnings = FALSE, recursive = TRUE)
ggsave("testing/output/gs_14_real_data_faceted.png", plot = p, width = 10, height = 4)
message("OK: testing/output/gs_14_real_data_faceted.png")
