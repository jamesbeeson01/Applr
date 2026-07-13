# gs_46 REFERENCE — slice at hp = 110 with BOTH ribbons: the wide prediction
# ribbon underneath and the narrow confidence ribbon nested on top, sharing
# one fitted line. Ground truth for two stacked geom_slice interval layers.
source("tests/reference/_ref_helpers.R")

model <- lm(mpg ~ disp + hp, data = mtcars)
xr <- range(mtcars$disp)
nd <- data.frame(disp = seq(xr[1], xr[2], length.out = 200), hp = 110)
conf <- cbind(nd, as.data.frame(predict(model, newdata = nd, interval = "confidence")))
pred <- cbind(nd, as.data.frame(predict(model, newdata = nd, interval = "prediction")))

p <- ggplot(mtcars, aes(disp, mpg)) +
  geom_point() +
  geom_ribbon(data = pred, aes(x = disp, ymin = lwr, ymax = upr),
              inherit.aes = FALSE, fill = "skyblue", alpha = 0.4) +
  geom_ribbon(data = conf, aes(x = disp, ymin = lwr, ymax = upr),
              inherit.aes = FALSE, fill = "skyblue", alpha = 0.4) +
  geom_line(data = conf, aes(disp, fit), color = "skyblue", linewidth = 1) +
  labs(title = "gs_46 REFERENCE — hp = 110 slice, confidence ribbon nested in prediction ribbon",
       subtitle = "Ground truth via predict(interval = ...) (no geom_slice, no geom_smooth)")

ggsave("tests/reference/gs_46_both_intervals.png", plot = p, width = 7, height = 5)
message("OK: tests/reference/gs_46_both_intervals.png")
