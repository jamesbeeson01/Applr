# gs_21 REFERENCE — y ~ I(x^2) plotted against x^2. Grid over the range of
# x^2, realized as x = sqrt(t), so the line is straight with slope 2.
source("tests/reference/_ref_helpers.R")
set.seed(123)
n <- 50
x <- runif(n, -5, 5)
y <- 2 * x^2 + 1
model <- lm(y ~ I(x^2))
dat <- data.frame(x, y)

t <- seq(min(x^2), max(x^2), length.out = 200)
ref <- data.frame(t = t, .pred = predict(model, newdata = data.frame(x = sqrt(t))))

p <- ggplot(dat, aes(x^2, y)) +
  geom_point(color = "steelblue") +
  geom_line(data = ref, aes(t, .pred), color = "skyblue", linewidth = 1) +
  labs(title = "gs_21 REFERENCE — y ~ I(x^2), x^2 on the x-axis",
       subtitle = "Ground truth via predict() (no geom_slice, no geom_smooth)")

ggsave("tests/reference/gs_21_xaxis_square.png", plot = p, width = 7, height = 5)
message("OK: tests/reference/gs_21_xaxis_square.png")
