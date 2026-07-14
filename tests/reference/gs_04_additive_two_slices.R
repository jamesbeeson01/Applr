# gs_04 REFERENCE — two parallel slices at x_pos = 1 (blue) and x_pos = 9 (red).
source("tests/reference/_ref_helpers.R")
set.seed(123)
n <- 50
x <- runif(n, -10, 10)
x_pos <- runif(n, 0, 10)
y <- x + x_pos + rnorm(n)
model <- lm(y ~ x + x_pos)
dat <- data.frame(x, y)

ref_lo <- ref_slice(model, dat, "x", held = list(x_pos = 1))
ref_hi <- ref_slice(model, dat, "x", held = list(x_pos = 9))

p <- ggplot(dat, aes(x, y)) +
  geom_point(color = "gray60") +
  geom_line(data = ref_lo, aes(x, .pred), color = "steelblue", linewidth = 1) +
  geom_line(data = ref_hi, aes(x, .pred), color = "firebrick", linewidth = 1) +
  labs(title = "gs_04 REFERENCE — two slices at x_pos=1 (blue) and x_pos=9 (red)",
       subtitle = "Ground truth via predict() (no geom_slice, no geom_smooth)")

ggsave("tests/reference/gs_04_additive_two_slices.png", plot = p, width = 7, height = 5)
message("OK: tests/reference/gs_04_additive_two_slices.png")
