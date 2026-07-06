# gs_05 REFERENCE — quadratic model (y ~ x + I(x^2)): an upward-opening parabola.
source("testing/reference/_ref_helpers.R")
set.seed(123)
n <- 50
x <- runif(n, -10, 10)
y <- x + x^2 + rnorm(n, sd = 3)
model <- lm(y ~ x + I(x^2))
dat <- data.frame(x, y)

ref <- ref_slice(model, dat, "x")

p <- ggplot(dat, aes(x, y)) +
  geom_point(color = "steelblue") +
  geom_line(data = ref, aes(x, .pred), color = "skyblue", linewidth = 1) +
  labs(title = "gs_05 REFERENCE — quadratic model (y ~ x + I(x^2))",
       subtitle = "Ground truth via predict() (no geom_slice, no geom_smooth)")

ggsave("testing/reference/gs_05_quadratic.png", plot = p, width = 7, height = 5)
message("OK: testing/reference/gs_05_quadratic.png")
