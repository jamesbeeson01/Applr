# gs_26 REFERENCE — log(y) ~ x plotted with log(y) mapped on the y-axis.
# The y-axis already shows the transformed response, so predictions are used
# as-is (NO back-transform): a straight line with slope 0.5 and intercept 1.
source("testing/reference/_ref_helpers.R")
set.seed(123)
n <- 50
x <- runif(n, 0, 10)
y <- exp(0.5 * x + 1)
model <- lm(log(y) ~ x)
dat <- data.frame(x, y)

ref <- ref_slice(model, dat, "x")

p <- ggplot(dat, aes(x, log(y))) +
  geom_point(color = "steelblue") +
  geom_line(data = ref, aes(x, .pred), color = "skyblue", linewidth = 1) +
  labs(title = "gs_26 REFERENCE — log(y) ~ x, inline log(y) on the y-axis",
       subtitle = "Ground truth via predict() (no geom_slice, no geom_smooth)")

ggsave("testing/reference/gs_26_inline_log_y.png", plot = p, width = 7, height = 5)
message("OK: testing/reference/gs_26_inline_log_y.png")
