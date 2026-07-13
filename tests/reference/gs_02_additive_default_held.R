# gs_02 REFERENCE — additive model, x_pos held at its mean (the geom_slice default).
source("tests/reference/_ref_helpers.R")
set.seed(123)
n <- 50
x <- runif(n, -10, 10)
x_pos <- runif(n, 0, 10)
y <- x + x_pos + rnorm(n)
model <- lm(y ~ x + x_pos)
dat <- data.frame(x, y)

ref <- ref_slice(model, dat, "x", held = list(x_pos = mean(x_pos)))

p <- ggplot(dat, aes(x, y)) +
  geom_point(color = "steelblue") +
  geom_line(data = ref, aes(x, .pred), color = "skyblue", linewidth = 1) +
  labs(title = "gs_02 REFERENCE — additive model, x_pos = mean(x_pos)",
       subtitle = "Ground truth via predict() (no geom_slice, no geom_smooth)")

ggsave("tests/reference/gs_02_additive_default_held.png", plot = p, width = 7, height = 5)
message("OK: tests/reference/gs_02_additive_default_held.png")
