# sb_12 REFERENCE — projection band on x2 (1 to 4); subtitle is the equation
# plus the band reported with range wording: "projection: x2 spanning 1-4".
source("tests/reference/_ref_helpers.R")
set.seed(123)
n <- 50
x <- runif(n, -10, 10)
x2 <- runif(n, 0, 5)
y <- x + 2 * x2 + rnorm(n)
dat <- data.frame(x, x2, y)
model <- lm(y ~ x + x2, data = dat)

lo <- ref_slice(model, dat, "x", held = list(x2 = 1))
hi <- ref_slice(model, dat, "x", held = list(x2 = 4))
band <- data.frame(x = lo$x, ymin = lo$.pred, ymax = hi$.pred)

p <- ggplot(dat, aes(x, y)) +
  geom_point(color = "gray60") +
  geom_ribbon(data = band, aes(x = x, ymin = ymin, ymax = ymax),
              inherit.aes = FALSE, fill = "skyblue", alpha = 0.3) +
  geom_line(data = lo, aes(x, .pred), color = "skyblue", linewidth = 1) +
  geom_line(data = hi, aes(x, .pred), color = "skyblue", linewidth = 1) +
  labs(title = "sb_12 REFERENCE — banded variable reported as 'spanning'",
       subtitle = paste0(ref_equation(model), "\nprojection: x2 spanning 1-4"))

ggsave("tests/reference/sb_12_band_spanning.png", plot = p, width = 7, height = 5)
message("OK: tests/reference/sb_12_band_spanning.png")
