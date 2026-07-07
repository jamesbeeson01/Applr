# gs_36 REFERENCE — six parallel slices, one per (x2, x3) combination:
# x2 in {1, 2, 3} (color) crossed with x3 in {1, 4} (linetype).
# The multi-value predict_vars feature is not implemented in geom_slice yet
# (dev_todo.Rmd); this is the ground truth it should reproduce once it is.
# Color/linetype only identify the lines — the feature's own styling is undesigned.
source("testing/reference/_ref_helpers.R")
set.seed(123)
n <- 60
x <- runif(n, -10, 10)
x2 <- runif(n, 0, 4)
x3 <- runif(n, 0, 5)
y <- x + 3 * x2 + 0.7 * x3 + rnorm(n)
dat <- data.frame(x, x2, x3, y)
model <- lm(y ~ x + x2 + x3, data = dat)

combos <- expand.grid(x2 = c(1, 2, 3), x3 = c(1, 4))
lines <- do.call(rbind, lapply(seq_len(nrow(combos)), function(i) {
  ref_slice(model, dat, "x", held = list(x2 = combos$x2[i], x3 = combos$x3[i]))
}))

p <- ggplot(dat, aes(x, y)) +
  geom_point(color = "gray60") +
  geom_line(data = lines,
            aes(x, .pred, color = factor(x2), linetype = factor(x3),
                group = interaction(x2, x3)),
            linewidth = 1) +
  labs(title = "gs_36 REFERENCE — six slices: x2 in {1,2,3} (color) x x3 in {1,4} (linetype)",
       subtitle = "Ground truth via predict() (no geom_slice, no geom_smooth)",
       color = "x2", linetype = "x3")

ggsave("testing/reference/gs_36_multi_value_crossed.png", plot = p, width = 7, height = 5)
message("OK: testing/reference/gs_36_multi_value_crossed.png")
