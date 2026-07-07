# gs_35 REFERENCE — three parallel slices at x_pos = 1 (blue), 5 (green), 9 (red).
# The multi-value predict_vars feature is not implemented in geom_slice yet
# (dev_todo.Rmd); this is the ground truth it should reproduce once it is.
# The colors only identify the lines — the feature's own styling is undesigned.
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
  geom_point(color = "gray60") +
  geom_line(data = ref_lo,  aes(x, .pred), color = "steelblue", linewidth = 1) +
  geom_line(data = ref_mid, aes(x, .pred), color = "seagreen",  linewidth = 1) +
  geom_line(data = ref_hi,  aes(x, .pred), color = "firebrick", linewidth = 1) +
  labs(title = "gs_35 REFERENCE — slices at x_pos = 1 (blue), 5 (green), 9 (red)",
       subtitle = "Ground truth via predict() (no geom_slice, no geom_smooth)")

ggsave("testing/reference/gs_35_multi_value_single_var.png", plot = p, width = 7, height = 5)
message("OK: testing/reference/gs_35_multi_value_single_var.png")
