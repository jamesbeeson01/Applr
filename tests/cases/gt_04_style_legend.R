# CASE: gt_04_style_legend
# TYPE: visual
# FUNC: geom_slice_text
# EXPECT: Six parallel skyblue slices (x2 in {0, 2, 4} x x3 in {0, 1}) with
#         style = "legend": each line's right end shows bare values joined
#         with "; " ("0; 0", "2; 1", ...), and a small key in the TOP-RIGHT
#         corner of the panel reads "labels: x2; x3". The corner key is
#         skyblue because all lines share one color, and the geom adds
#         y-headroom itself so the key clears the topmost line's label.

source("testing/_setup.R")
set.seed(123)

n <- 60
x <- runif(n, -10, 10)
x2 <- runif(n, 0, 4)
x3 <- runif(n, 0, 2)
y <- x + 4 * x2 + 3 * x3 + rnorm(n)
dat <- data.frame(x, x2, x3, y)
model <- lm(y ~ x + x2 + x3, data = dat)

p <- ggplot(dat, aes(x, y)) +
  geom_point(color = "gray60") +
  geom_slice(model, predict_vars = list(x2 = c(0, 2, 4), x3 = c(0, 1))) +
  geom_slice_text(style = "legend") +
  labs(title = "gt_04: style = \"legend\" — bare values + corner key",
       subtitle = "EXPECT: values at line ends, 'labels: x2; x3' top-right")
p
