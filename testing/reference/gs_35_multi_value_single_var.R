# gs_35 REFERENCE — three parallel slices at x_pos = 1, 5, 9.
# Ground truth for multi-value predict_vars (one line per value). The colors
# only identify the lines — geom_slice draws all three in its default color.
source("testing/reference/_ref_helpers.R")
set.seed(123)
n <- 50
x <- runif(n, -10, 10)
x_pos <- runif(n, 0, 10)
y <- x + x_pos + rnorm(n)
dat <- data.frame(x, x_pos, y)
model <- lm(y ~ x + x_pos, data = dat)

ref_lo  <- ref_slice(model, dat, "x", held = list(x_pos = 1))
ref_mid <- ref_slice(model, dat, "x", held = list(x_pos = 5))
ref_hi  <- ref_slice(model, dat, "x", held = list(x_pos = 9))

p <- ggplot(dat, aes(x, y)) +
  geom_point() +
  geom_line(data = ref_lo,  aes(x, .pred), color = "skyblue", linewidth = 1) +
  geom_line(data = ref_mid, aes(x, .pred), color = "skyblue",  linewidth = 1) +
  geom_line(data = ref_hi,  aes(x, .pred), color = "skyblue", linewidth = 1) +
  labs(title = "gs_35 REFERENCE — slices at x_pos = 1, 5, 9",
       subtitle = "Ground truth via predict() (no geom_slice, no geom_smooth)")

ggsave("testing/reference/gs_35_multi_value_single_var.png", plot = p, width = 7, height = 5)
message("OK: testing/reference/gs_35_multi_value_single_var.png")
