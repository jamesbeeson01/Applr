# gs_10 REFERENCE — sqrt(y) ~ x_pos, plotted on the original y scale. Predictions
# are back-transformed by squaring, giving a parabola-shaped curve.
source("tests/reference/_ref_helpers.R")
set.seed(123)
n <- 50
x_pos <- runif(n, 0, 10)
y <- x_pos^2 + rnorm(n, sd = 2)
y <- pmax(y, 0)
model <- lm(sqrt(y) ~ x_pos)
dat <- data.frame(x_pos, y)

ref <- ref_slice(model, dat, "x_pos", back_transform = function(z) z^2)

p <- ggplot(dat, aes(x_pos, y)) +
  geom_point(color = "steelblue") +
  geom_line(data = ref, aes(x_pos, .pred), color = "skyblue", linewidth = 1) +
  labs(title = "gs_10 REFERENCE — sqrt(y) ~ x_pos, back-transformed by squaring",
       subtitle = "Ground truth via predict() (no geom_slice, no geom_smooth)")

ggsave("tests/reference/gs_10_ytransform_sqrt.png", plot = p, width = 7, height = 5)
message("OK: tests/reference/gs_10_ytransform_sqrt.png")
