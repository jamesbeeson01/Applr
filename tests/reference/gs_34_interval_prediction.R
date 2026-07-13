# gs_34 REFERENCE — slice at hp = 110 with its PREDICTION ribbon.
# Ground truth for geom_slice(interval = "prediction").
source("testing/reference/_ref_helpers.R")

model <- lm(mpg ~ disp + hp, data = mtcars)
xr <- range(mtcars$disp)
nd <- data.frame(disp = seq(xr[1], xr[2], length.out = 200), hp = 110)
ref <- cbind(nd, as.data.frame(predict(model, newdata = nd, interval = "prediction")))

p <- ggplot(mtcars, aes(disp, mpg)) +
  geom_point() +
  geom_ribbon(data = ref, aes(x = disp, ymin = lwr, ymax = upr),
              inherit.aes = FALSE, fill = "skyblue", alpha = 0.4) +
  geom_line(data = ref, aes(disp, fit), color = "skyblue", linewidth = 1) +
  labs(title = "gs_34 REFERENCE — slice at hp = 110 with WIDE prediction ribbon",
       subtitle = "Ground truth via predict(interval = \"prediction\") (no geom_slice, no geom_smooth)")

ggsave("testing/reference/gs_34_interval_prediction.png", plot = p, width = 7, height = 5)
message("OK: testing/reference/gs_34_interval_prediction.png")
