# gs_01 REFERENCE — single predictor (y ~ x). Ground truth, no geom_slice/geom_smooth.
source("testing/reference/_ref_helpers.R")
set.seed(123)
n <- 50
x <- runif(n, -10, 10)
y <- x
model <- lm(y ~ x)
dat <- data.frame(x, y)

ref <- ref_slice(model, dat, "x")

p <- ggplot(dat, aes(x, y)) +
  geom_point(color = "steelblue") +
  geom_line(data = ref, aes(x, .pred), color = "skyblue", linewidth = 1) +
  labs(title = "gs_01 REFERENCE — single predictor (y ~ x)",
       subtitle = "Ground truth via predict() (no geom_slice, no geom_smooth)")

ggsave("testing/reference/gs_01_single_predictor.png", plot = p, width = 7, height = 5)
message("OK: testing/reference/gs_01_single_predictor.png")
