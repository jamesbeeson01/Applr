# gs_49 REFERENCE — projection band between the x_pos = 1 and x_pos = 9 slices.
# Ground truth for geom_slice(predict_vars = list(x_pos = c(1, 9)), band = TRUE).
source("tests/reference/_ref_helpers.R")
set.seed(123)
n <- 50
x <- runif(n, -10, 10)
x_pos <- runif(n, 0, 10)
y <- x + x_pos + rnorm(n)
dat <- data.frame(x, x_pos, y)
model <- lm(y ~ x + x_pos, data = dat)

lo <- ref_slice(model, dat, "x", held = list(x_pos = 1))
hi <- ref_slice(model, dat, "x", held = list(x_pos = 9))
band <- data.frame(x = lo$x, ymin = lo$.pred, ymax = hi$.pred)

p <- ggplot(dat, aes(x, y)) +
  geom_point() +
  geom_ribbon(data = band, aes(x = x, ymin = ymin, ymax = ymax),
              inherit.aes = FALSE, fill = "skyblue", alpha = 0.3) +
  geom_line(data = lo, aes(x, .pred), color = "skyblue", linewidth = 1) +
  geom_line(data = hi, aes(x, .pred), color = "skyblue", linewidth = 1) +
  labs(title = "gs_49 REFERENCE — band between x_pos = 1 and x_pos = 9 slices",
       subtitle = "Ground truth via predict() at both extremes + ribbon between (no geom_slice)")

ggsave("tests/reference/gs_49_band_two_values.png", plot = p, width = 7, height = 5)
message("OK: tests/reference/gs_49_band_two_values.png")
