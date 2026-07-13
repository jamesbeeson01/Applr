# gs_24 REFERENCE — y ~ x displayed with scale_x_log10(). Predictions are made
# in raw data space; the scale transforms the line and the points identically,
# so the line passes exactly through the points (curving upward on the log axis).
source("testing/reference/_ref_helpers.R")
set.seed(123)
n <- 50
x <- runif(n, 1, 100)
y <- 2 * x + 10
model <- lm(y ~ x)
dat <- data.frame(x, y)

ref <- ref_slice(model, dat, "x")

p <- ggplot(dat, aes(x, y)) +
  geom_point(color = "steelblue") +
  geom_line(data = ref, aes(x, .pred), color = "skyblue", linewidth = 1) +
  scale_x_log10() +
  labs(title = "gs_24 REFERENCE — y ~ x with scale_x_log10()",
       subtitle = "Ground truth via predict() (no geom_slice, no geom_smooth)")

ggsave("testing/reference/gs_24_scale_x_log10.png", plot = p, width = 7, height = 5)
message("OK: testing/reference/gs_24_scale_x_log10.png")
