# ap_11 REFERENCE — autoplot(lm(mpg ~ disp), interval = "confidence").
# Ground truth for autoplot.lm() forwarding ... to geom_slice(): a single
# slice over disp with its CONFIDENCE ribbon. No geom_slice, no geom_smooth.
source("tests/reference/_ref_helpers.R")

model <- lm(mpg ~ disp, data = mtcars)
xr <- range(mtcars$disp)
nd <- data.frame(disp = seq(xr[1], xr[2], length.out = 200))
ref <- cbind(nd, as.data.frame(predict(model, newdata = nd, interval = "confidence")))

p <- ggplot(mtcars, aes(disp, mpg)) +
  geom_point() +
  geom_ribbon(data = ref, aes(x = disp, ymin = lwr, ymax = upr),
              inherit.aes = FALSE, fill = "skyblue", alpha = 0.4) +
  geom_line(data = ref, aes(disp, fit), color = "skyblue", linewidth = 1) +
  labs(title = "ap_11 REFERENCE — autoplot(mpg ~ disp) with confidence ribbon",
       subtitle = "Ground truth via predict(interval = \"confidence\") (no geom_slice, no geom_smooth)")

ggsave("tests/reference/ap_11_passthrough_args.png", plot = p, width = 7, height = 5)
message("OK: tests/reference/ap_11_passthrough_args.png")
