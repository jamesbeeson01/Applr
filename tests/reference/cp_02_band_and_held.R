# cp_02 REFERENCE — band on x2 (1 to 4) with x3 pinned at 2; the CAPTION
# (bottom-right) is the equation, the held line for x3, and the projection
# line for x2.
source("tests/reference/_ref_helpers.R")
set.seed(123)
n <- 50
x <- runif(n, -10, 10)
x2 <- runif(n, 0, 5)
x3 <- runif(n, 0, 4)
y <- x + 2 * x2 + x3 + rnorm(n)
dat <- data.frame(x, x2, x3, y)
model <- lm(y ~ x + x2 + x3, data = dat)

lo <- ref_slice(model, dat, "x", held = list(x2 = 1, x3 = 2))
hi <- ref_slice(model, dat, "x", held = list(x2 = 4, x3 = 2))
band <- data.frame(x = lo$x, ymin = lo$.pred, ymax = hi$.pred)

p <- ggplot(dat, aes(x, y)) +
  geom_point(color = "gray60") +
  geom_ribbon(data = band, aes(x = x, ymin = ymin, ymax = ymax),
              inherit.aes = FALSE, fill = "skyblue", alpha = 0.3) +
  geom_line(data = lo, aes(x, .pred), color = "skyblue", linewidth = 1) +
  geom_line(data = hi, aes(x, .pred), color = "skyblue", linewidth = 1) +
  labs(title = "cp_02 REFERENCE — held value and span in the caption",
       caption = paste0(ref_equation(model),
                        "\n", ref_held_line(list(x3 = 2)),
                        "\nprojection band: x2 spanning 1-4"))

ggsave("tests/reference/cp_02_band_and_held.png", plot = p, width = 7, height = 5)
message("OK: tests/reference/cp_02_band_and_held.png")
