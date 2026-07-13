# gs_41 REFERENCE — log(y) ~ x_pos with the named-string back_transform =
# "log" (predictions exp()'d). Identical ground truth to gs_09: an upward
# exponential curve on the original y scale.
source("testing/reference/_ref_helpers.R")
set.seed(123)
n <- 50
x_pos <- runif(n, 0, 10)
y <- exp(x_pos) * exp(rnorm(n, sd = 0.2))
model <- lm(log(y) ~ x_pos)
dat <- data.frame(x_pos, y)

ref <- ref_slice(model, dat, "x_pos", back_transform = exp)

p <- ggplot(dat, aes(x_pos, y)) +
  geom_point(color = "steelblue") +
  geom_line(data = ref, aes(x_pos, .pred), color = "skyblue", linewidth = 1) +
  labs(title = "gs_41 REFERENCE — log(y) ~ x_pos, back_transform = \"log\"",
       subtitle = "Ground truth via predict() (no geom_slice, no geom_smooth)")

ggsave("testing/reference/gs_41_back_transform_string.png", plot = p, width = 7, height = 5)
message("OK: testing/reference/gs_41_back_transform_string.png")
