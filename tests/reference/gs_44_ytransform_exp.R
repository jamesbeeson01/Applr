# gs_44 REFERENCE — exp(y) ~ x_pos, plotted on the original y scale.
# Predictions are back-transformed with log(): a logarithmic curve.
source("testing/reference/_ref_helpers.R")
set.seed(123)
n <- 50
x_pos <- runif(n, 0.5, 10)
y <- log(x_pos) + rnorm(n, sd = 0.1)
model <- lm(exp(y) ~ x_pos)
dat <- data.frame(x_pos, y)

ref <- ref_slice(model, dat, "x_pos", back_transform = log)

p <- ggplot(dat, aes(x_pos, y)) +
  geom_point(color = "steelblue") +
  geom_line(data = ref, aes(x_pos, .pred), color = "skyblue", linewidth = 1) +
  labs(title = "gs_44 REFERENCE — exp(y) ~ x_pos, back-transformed with log()",
       subtitle = "Ground truth via predict() (no geom_slice, no geom_smooth)")

ggsave("testing/reference/gs_44_ytransform_exp.png", plot = p, width = 7, height = 5)
message("OK: testing/reference/gs_44_ytransform_exp.png")
