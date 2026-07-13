# gs_19 REFERENCE — y ~ I(x * x_pos) plotted against the product x * x_pos.
# The model depends on the predictors only through the product, so the ground
# truth is the prediction as a function of the product: a grid over the
# product's range, realized as (x = t, x_pos = 1) so that x * x_pos == t.
source("tests/reference/_ref_helpers.R")
set.seed(123)
n <- 50
x <- runif(n, -10, 10)
x_pos <- runif(n, 0, 10)
y <- x * x_pos
model <- lm(y ~ I(x * x_pos))
dat <- data.frame(x, x_pos, y)

t <- seq(min(x * x_pos), max(x * x_pos), length.out = 200)
ref <- data.frame(t = t, .pred = predict(model, newdata = data.frame(x = t, x_pos = 1)))

p <- ggplot(dat, aes(x * x_pos, y)) +
  geom_point(color = "steelblue") +
  geom_line(data = ref, aes(t, .pred), color = "skyblue", linewidth = 1) +
  labs(title = "gs_19 REFERENCE — y ~ I(x * x_pos), product on the x-axis",
       subtitle = "Ground truth via predict() (no geom_slice, no geom_smooth)")

ggsave("tests/reference/gs_19_xaxis_product.png", plot = p, width = 7, height = 5)
message("OK: tests/reference/gs_19_xaxis_product.png")
