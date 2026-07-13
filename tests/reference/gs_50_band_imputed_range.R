# gs_50 REFERENCE — projection band spanning the OBSERVED range of x_pos.
# Ground truth for geom_slice(band = "x_pos") with no predict_vars: the band
# runs between slices at min(x_pos) and max(x_pos) from the data.
source("testing/reference/_ref_helpers.R")
set.seed(123)
n <- 50
x <- runif(n, -10, 10)
x_pos <- runif(n, 0, 10)
y <- x + x_pos + rnorm(n)
dat <- data.frame(x, x_pos, y)
model <- lm(y ~ x + x_pos, data = dat)

r <- range(dat$x_pos)
lo <- ref_slice(model, dat, "x", held = list(x_pos = r[1]))
hi <- ref_slice(model, dat, "x", held = list(x_pos = r[2]))
band <- data.frame(x = lo$x, ymin = lo$.pred, ymax = hi$.pred)

p <- ggplot(dat, aes(x, y)) +
  geom_point() +
  geom_ribbon(data = band, aes(x = x, ymin = ymin, ymax = ymax),
              inherit.aes = FALSE, fill = "skyblue", alpha = 0.3) +
  geom_line(data = lo, aes(x, .pred), color = "skyblue", linewidth = 1) +
  geom_line(data = hi, aes(x, .pred), color = "skyblue", linewidth = 1) +
  labs(title = "gs_50 REFERENCE — band spanning observed min/max of x_pos",
       subtitle = "Ground truth: slices at range(x_pos) + ribbon between (no geom_slice)")

ggsave("testing/reference/gs_50_band_imputed_range.png", plot = p, width = 7, height = 5)
message("OK: testing/reference/gs_50_band_imputed_range.png")
