# gs_42 REFERENCE — 1/y ~ x with back_transform = FALSE, plotted against the
# precomputed transformed response y_trans = 1/y. Raw predictions match the
# axis: a straight line of slope ~1.
source("testing/reference/_ref_helpers.R")
set.seed(123)
n <- 50
x <- runif(n, 1, 10)
y <- 1/x + rnorm(n, sd = 0.05)
model <- lm(1/y ~ x)
dat <- data.frame(x, y_trans = 1/y)

ref <- ref_slice(model, dat, "x")  # identity: predictions used as-is

p <- ggplot(dat, aes(x, y_trans)) +
  geom_point(color = "steelblue") +
  geom_line(data = ref, aes(x, .pred), color = "skyblue", linewidth = 1) +
  labs(title = "gs_42 REFERENCE — 1/y ~ x, back_transform = FALSE",
       subtitle = "Ground truth via predict() (no geom_slice, no geom_smooth)")

ggsave("testing/reference/gs_42_back_transform_false.png", plot = p, width = 7, height = 5)
message("OK: testing/reference/gs_42_back_transform_false.png")
