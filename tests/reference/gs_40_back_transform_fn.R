# gs_40 REFERENCE — 1/y ~ x with an explicit back_transform = \(z) 1/z.
# Identical ground truth to gs_11 (the explicit function equals the inferred
# inverse): a decreasing hyperbolic curve.
source("tests/reference/_ref_helpers.R")
set.seed(123)
n <- 50
x <- runif(n, 1, 10)
y <- 1/x + rnorm(n, sd = 0.05)
model <- lm(1/y ~ x)
dat <- data.frame(x, y)

ref <- ref_slice(model, dat, "x", back_transform = function(z) 1/z)

p <- ggplot(dat, aes(x, y)) +
  geom_point(color = "steelblue") +
  geom_line(data = ref, aes(x, .pred), color = "skyblue", linewidth = 1) +
  labs(title = "gs_40 REFERENCE — 1/y ~ x, explicit back_transform = \\(z) 1/z",
       subtitle = "Ground truth via predict() (no geom_slice, no geom_smooth)")

ggsave("tests/reference/gs_40_back_transform_fn.png", plot = p, width = 7, height = 5)
message("OK: tests/reference/gs_40_back_transform_fn.png")
