# sb_08 REFERENCE — single-predictor model, nothing held: the subtitle is the
# equation line alone, with no "held at:" line.
source("tests/reference/_ref_helpers.R")
set.seed(123)
n <- 40
x <- runif(n, -10, 10)
y <- 2 * x + 3 + rnorm(n)
dat <- data.frame(x, y)
model <- lm(y ~ x, data = dat)

s <- ref_slice(model, dat, "x")

p <- ggplot(dat, aes(x, y)) +
  geom_point(color = "gray60") +
  geom_line(data = s, aes(x, .pred), color = "skyblue", linewidth = 1) +
  labs(title = "sb_08 REFERENCE — nothing held, equation line only",
       subtitle = ref_equation(model))

ggsave("tests/reference/sb_08_nothing_held.png", plot = p, width = 7, height = 5)
message("OK: tests/reference/sb_08_nothing_held.png")
