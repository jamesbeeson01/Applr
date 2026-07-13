# sb_02 REFERENCE — one slice with x2 pinned at 1 by predict_vars; subtitle is
# the equation plus "held at: x2 = 1".
source("testing/reference/_ref_helpers.R")
set.seed(123)
n <- 50
x <- runif(n, -10, 10)
x2 <- runif(n, 0, 5)
y <- x + 2 * x2 + rnorm(n)
dat <- data.frame(x, x2, y)
model <- lm(y ~ x + x2, data = dat)

held <- list(x2 = 1)
s <- ref_slice(model, dat, "x", held = held)

p <- ggplot(dat, aes(x, y)) +
  geom_point(color = "gray60") +
  geom_line(data = s, aes(x, .pred), color = "skyblue", linewidth = 1) +
  labs(title = "sb_02 REFERENCE — predict_vars value in the subtitle",
       subtitle = paste0(ref_equation(model), "\n", ref_held_line(held)))

ggsave("testing/reference/sb_02_predict_vars.png", plot = p, width = 7, height = 5)
message("OK: testing/reference/sb_02_predict_vars.png")
