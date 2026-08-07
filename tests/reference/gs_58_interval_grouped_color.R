# gs_58 REFERENCE — mpg: hwy ~ displ + I(displ^2) + displ:drv, auto-grouped by
# color = drv, with a 95% CONFIDENCE ribbon per group. Ground truth for the
# rule that an interval ribbon takes its line's colour when `fill` is not set:
# each ribbon here is filled with its own group's colour at alpha 0.4.
source("tests/reference/_ref_helpers.R")

model <- lm(hwy ~ displ + I(displ^2) + displ:drv, data = mpg)

ref <- do.call(rbind, lapply(sort(unique(mpg$drv)), function(v) {
  d <- subset(mpg, drv == v)
  xr <- range(d$displ)
  nd <- data.frame(displ = seq(xr[1], xr[2], length.out = 200), drv = v)
  cbind(nd, as.data.frame(predict(model, newdata = nd, interval = "confidence")))
}))

p <- ggplot(mpg, aes(displ, hwy, color = drv)) +
  geom_point() +
  geom_ribbon(data = ref, aes(x = displ, ymin = lwr, ymax = upr, fill = drv),
              inherit.aes = FALSE, alpha = 0.4) +
  geom_line(data = ref, aes(displ, fit, color = drv), linewidth = 1) +
  scale_fill_hue(guide = "none") +
  labs(title = "gs_58 REFERENCE — confidence ribbon per drv, filled in the group colour",
       subtitle = "Ground truth via predict(interval = \"confidence\") (no geom_slice, no geom_smooth)")

ggsave("tests/reference/gs_58_interval_grouped_color.png", plot = p, width = 7, height = 5)
message("OK: tests/reference/gs_58_interval_grouped_color.png")
