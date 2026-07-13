# gs_20 REFERENCE — y ~ log(x) plotted against log(x). Grid over the range of
# log(x), realized as x = exp(t), so the line is straight with slope 3.
source("tests/reference/_ref_helpers.R")
set.seed(123)
n <- 50
x <- runif(n, 0.5, 20)
y <- 3 * log(x) + 2
model <- lm(y ~ log(x))
dat <- data.frame(x, y)

t <- seq(min(log(x)), max(log(x)), length.out = 200)
ref <- data.frame(t = t, .pred = predict(model, newdata = data.frame(x = exp(t))))

p <- ggplot(dat, aes(log(x), y)) +
  geom_point(color = "steelblue") +
  geom_line(data = ref, aes(t, .pred), color = "skyblue", linewidth = 1) +
  labs(title = "gs_20 REFERENCE — y ~ log(x), log(x) on the x-axis",
       subtitle = "Ground truth via predict() (no geom_slice, no geom_smooth)")

ggsave("tests/reference/gs_20_xaxis_log.png", plot = p, width = 7, height = 5)
message("OK: tests/reference/gs_20_xaxis_log.png")
