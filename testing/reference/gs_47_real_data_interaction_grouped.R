# gs_47 REFERENCE — mpg: hwy ~ displ + I(displ^2) + displ:drv, auto-grouped
# by color = drv. One quadratic curve per drive type in its natural ggplot
# color, each spanning only its group's displ range (the decisions.Rmd
# group-range rule).
source("testing/reference/_ref_helpers.R")

model <- lm(hwy ~ displ + I(displ^2) + displ:drv, data = mpg)

ref <- do.call(rbind, lapply(sort(unique(mpg$drv)), function(v) {
  d <- ref_slice(model, subset(mpg, drv == v), "displ", held = list(drv = v))
  d$drv <- v
  d
}))

p <- ggplot(mpg, aes(displ, hwy, color = drv)) +
  geom_point() +
  geom_line(data = ref, aes(displ, .pred, color = drv), linewidth = 1) +
  labs(title = "gs_47 REFERENCE — quadratic interaction, one curve per drv (per-group x range)",
       subtitle = "Ground truth via predict() (no geom_slice, no geom_smooth)")

ggsave("testing/reference/gs_47_real_data_interaction_grouped.png", plot = p, width = 7, height = 5)
message("OK: testing/reference/gs_47_real_data_interaction_grouped.png")
