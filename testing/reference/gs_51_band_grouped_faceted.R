# gs_51 REFERENCE — one projection band (cyl = 4 to cyl = 8) per drv group,
# faceted by year, each band in its group's natural color and spanning only
# that group's displ range within its facet.
# Ground truth for geom_slice(predict_vars = list(cyl = c(4, 8)), band = TRUE)
# on a drv-colored, year-faceted mpg plot.
source("testing/reference/_ref_helpers.R")

model <- lm(hwy ~ displ * drv + cyl, data = mpg)

bands <- do.call(rbind, lapply(split(mpg, list(mpg$year, mpg$drv)), function(d) {
  lo <- ref_slice(model, d, "displ", held = list(drv = d$drv[1], cyl = 4))
  hi <- ref_slice(model, d, "displ", held = list(drv = d$drv[1], cyl = 8))
  data.frame(displ = lo$displ, ymin = lo$.pred, ymax = hi$.pred,
             drv = d$drv[1], year = d$year[1])
}))

p <- ggplot(mpg, aes(displ, hwy, color = drv)) +
  geom_point() +
  geom_ribbon(data = bands, aes(x = displ, ymin = ymin, ymax = ymax, fill = drv),
              inherit.aes = FALSE, alpha = 0.3, show.legend = FALSE) +
  geom_line(data = bands, aes(displ, ymin, color = drv), linewidth = 1) +
  geom_line(data = bands, aes(displ, ymax, color = drv), linewidth = 1) +
  facet_wrap(~year) +
  labs(title = "gs_51 REFERENCE — cyl 4-8 band per drv group, faceted by year",
       subtitle = "Ground truth via predict() at cyl = 4 and cyl = 8 per group subset (no geom_slice)")

ggsave("testing/reference/gs_51_band_grouped_faceted.png", plot = p, width = 10, height = 5)
message("OK: testing/reference/gs_51_band_grouped_faceted.png")
