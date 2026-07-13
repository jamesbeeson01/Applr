# gs_11 REFERENCE — 1/y ~ x, plotted on the original y scale. Predictions are
# back-transformed with 1/(.), giving a decreasing hyperbolic curve.
source("testing/reference/_ref_helpers.R")
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
  labs(title = "gs_11 REFERENCE — 1/y ~ x, back-transformed with 1/(.)",
       subtitle = "Ground truth via predict() (no geom_slice, no geom_smooth)")

ggsave("testing/reference/gs_11_ytransform_inverse.png", plot = p, width = 7, height = 5)
message("OK: testing/reference/gs_11_ytransform_inverse.png")
