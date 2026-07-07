# gs_25 REFERENCE — y ~ x displayed with scale_y_log10(). Predictions are made
# in raw data space; the scale transforms the line and the points identically,
# so the line passes exactly through the points (flattening on the log axis).
source("testing/reference/_ref_helpers.R")
set.seed(123)
n <- 50
x <- runif(n, 0.5, 10)
y <- 3 * x + 2
model <- lm(y ~ x)
dat <- data.frame(x, y)

ref <- ref_slice(model, dat, "x")

p <- ggplot(dat, aes(x, y)) +
  geom_point(color = "steelblue") +
  geom_line(data = ref, aes(x, .pred), color = "skyblue", linewidth = 1) +
  scale_y_log10() +
  labs(title = "gs_25 REFERENCE — y ~ x with scale_y_log10()",
       subtitle = "Ground truth via predict() (no geom_slice, no geom_smooth)")

ggsave("testing/reference/gs_25_scale_y_log10.png", plot = p, width = 7, height = 5)
message("OK: testing/reference/gs_25_scale_y_log10.png")
