# gs_43 REFERENCE — 1/y ~ x plotted with 1/y mapped inline on the y-axis.
# The axis already shows the transformed response, so predictions are used
# as-is (NO back-transform): a straight line of slope ~1.
source("tests/reference/_ref_helpers.R")
set.seed(123)
n <- 50
x <- runif(n, 1, 10)
y <- 1/x + rnorm(n, sd = 0.05)
model <- lm(1/y ~ x)
dat <- data.frame(x, y)

ref <- ref_slice(model, dat, "x")  # identity: predictions used as-is

p <- ggplot(dat, aes(x, 1/y)) +
  geom_point(color = "steelblue") +
  geom_line(data = ref, aes(x, .pred), color = "skyblue", linewidth = 1) +
  labs(title = "gs_43 REFERENCE — 1/y ~ x, inline 1/y on the y-axis",
       subtitle = "Ground truth via predict() (no geom_slice, no geom_smooth)")

ggsave("tests/reference/gs_43_ytransform_inverse_axis.png", plot = p, width = 7, height = 5)
message("OK: tests/reference/gs_43_ytransform_inverse_axis.png")
