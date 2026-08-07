# gs_59 REFERENCE — one projection band per drv group with the band variable
# INFERRED: hwy ~ displ * drv + cyl leaves cyl as the only predictor the plot
# does not show, and with no predict_vars its range comes from the data (4 to
# 8). Each band is drawn in its group's natural color and spans only that
# group's displ range.
# Ground truth for geom_slice(band = TRUE) on a drv-colored mpg plot.
source("tests/reference/_ref_helpers.R")

model <- lm(hwy ~ displ * drv + cyl, data = mpg)
cyl_range <- range(mpg$cyl)

bands <- do.call(rbind, lapply(sort(unique(mpg$drv)), function(v) {
  d <- subset(mpg, drv == v)
  lo <- ref_slice(model, d, "displ", held = list(drv = v, cyl = cyl_range[1]))
  hi <- ref_slice(model, d, "displ", held = list(drv = v, cyl = cyl_range[2]))
  data.frame(displ = lo$displ, ymin = lo$.pred, ymax = hi$.pred, drv = v)
}))

p <- ggplot(mpg, aes(displ, hwy, color = drv)) +
  geom_point() +
  geom_ribbon(data = bands, aes(x = displ, ymin = ymin, ymax = ymax, fill = drv),
              inherit.aes = FALSE, alpha = 0.3, show.legend = FALSE) +
  geom_line(data = bands, aes(displ, ymin, color = drv), linewidth = 1) +
  geom_line(data = bands, aes(displ, ymax, color = drv), linewidth = 1) +
  labs(title = "gs_59 REFERENCE — inferred cyl band per drv group, in the group colour",
       subtitle = "Ground truth via predict() at cyl = 4 and cyl = 8 per group subset (no geom_slice)")

ggsave("tests/reference/gs_59_band_true_grouped_color.png", plot = p, width = 7, height = 5)
message("OK: tests/reference/gs_59_band_true_grouped_color.png")
