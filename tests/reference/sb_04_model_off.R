# sb_04 REFERENCE — same slice as sb_01, subtitle is the held-values line only
# (model = FALSE drops the equation line).
source("testing/reference/_ref_helpers.R")
set.seed(123)
n <- 50
x <- runif(n, -10, 10)
x2 <- runif(n, 0, 5)
y <- x + 2 * x2 + rnorm(n)
dat <- data.frame(x, x2, y)
model <- lm(y ~ x + x2, data = dat)

held <- list(x2 = mean(dat$x2))
s <- ref_slice(model, dat, "x", held = held)

p <- ggplot(dat, aes(x, y)) +
  geom_point(color = "gray60") +
  geom_line(data = s, aes(x, .pred), color = "skyblue", linewidth = 1) +
  labs(title = "sb_04 REFERENCE — model = FALSE, values line only",
       subtitle = ref_held_line(held))

ggsave("testing/reference/sb_04_model_off.png", plot = p, width = 7, height = 5)
message("OK: testing/reference/sb_04_model_off.png")
