# gs_22 REFERENCE — y ~ I(1/x) plotted against 1/x. Grid over the range of
# 1/x, realized as x = 1/t, so the line is straight with slope 5.
source("tests/reference/_ref_helpers.R")
set.seed(123)
n <- 50
x <- runif(n, 0.5, 10)
y <- 5 / x + 2
model <- lm(y ~ I(1/x))
dat <- data.frame(x, y)

t <- seq(min(1/x), max(1/x), length.out = 200)
ref <- data.frame(t = t, .pred = predict(model, newdata = data.frame(x = 1/t)))

p <- ggplot(dat, aes(1/x, y)) +
  geom_point(color = "steelblue") +
  geom_line(data = ref, aes(t, .pred), color = "skyblue", linewidth = 1) +
  labs(title = "gs_22 REFERENCE — y ~ I(1/x), 1/x on the x-axis",
       subtitle = "Ground truth via predict() (no geom_slice, no geom_smooth)")

ggsave("tests/reference/gs_22_xaxis_inverse.png", plot = p, width = 7, height = 5)
message("OK: tests/reference/gs_22_xaxis_inverse.png")
