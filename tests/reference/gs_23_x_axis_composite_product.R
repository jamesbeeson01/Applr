# gs_23 REFERENCE — y ~ x2:x3:x6 + x1:x2:x3 plotted against x2*x3*(x1+x6).
# Since x2*x3*(x1+x6) = x1*x2*x3 + x2*x3*x6 and the fit is exact, predictions
# depend on the predictors only through that composite value t. The grid is
# realized as (x1 = t, x2 = 1, x3 = 1, x6 = 0) so the composite equals t.
source("testing/reference/_ref_helpers.R")
set.seed(123)
n <- 50
x1 <- runif(n, -5, 5)
x2 <- runif(n, -5, 5)
x3 <- runif(n, -5, 5)
x6 <- runif(n, -5, 5)
y <- x2 * x3 * (x1 + x6)
model <- lm(y ~ x2:x3:x6 + x1:x2:x3)
dat <- data.frame(x1, x2, x3, x6, y)

comp <- x2 * x3 * (x1 + x6)
t <- seq(min(comp), max(comp), length.out = 200)
ref <- data.frame(
  t = t,
  .pred = predict(model, newdata = data.frame(x1 = t, x2 = 1, x3 = 1, x6 = 0))
)

p <- ggplot(dat, aes(x2 * x3 * (x1 + x6), y)) +
  geom_point(color = "steelblue") +
  geom_line(data = ref, aes(t, .pred), color = "skyblue", linewidth = 1) +
  labs(title = "gs_23 REFERENCE — y ~ x2:x3:x6 + x1:x2:x3, composite product axis",
       subtitle = "Ground truth via predict() (no geom_slice, no geom_smooth)")

ggsave("testing/reference/gs_23_xaxis_composite_product.png", plot = p, width = 7, height = 5)
message("OK: testing/reference/gs_23_xaxis_composite_product.png")
