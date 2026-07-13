# gs_45 REFERENCE — y^2 ~ x_pos, plotted on the original y scale.
# Predictions are back-transformed with sqrt(): a square-root curve.
source("testing/reference/_ref_helpers.R")
set.seed(123)
n <- 50
x_pos <- runif(n, 0.5, 10)
y <- sqrt(x_pos) + rnorm(n, sd = 0.05)
model <- lm(y^2 ~ x_pos)
dat <- data.frame(x_pos, y)

ref <- ref_slice(model, dat, "x_pos", back_transform = sqrt)

p <- ggplot(dat, aes(x_pos, y)) +
  geom_point(color = "steelblue") +
  geom_line(data = ref, aes(x_pos, .pred), color = "skyblue", linewidth = 1) +
  labs(title = "gs_45 REFERENCE — y^2 ~ x_pos, back-transformed with sqrt()",
       subtitle = "Ground truth via predict() (no geom_slice, no geom_smooth)")

ggsave("testing/reference/gs_45_ytransform_square.png", plot = p, width = 7, height = 5)
message("OK: testing/reference/gs_45_ytransform_square.png")
