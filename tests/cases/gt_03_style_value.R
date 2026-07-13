# CASE: gt_03_style_value
# TYPE: visual
# FUNC: geom_slice_text
# EXPECT: Same two parallel slices as gt_01 (x2 held at 0 and 4), but with
#         style = "value": the labels are bare values with no variable name —
#         "0" on the lower line, "4" on the upper line. Skyblue, right ends.

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
x2 <- runif(n, 0, 5)
y <- x + 2 * x2 + rnorm(n)
dat <- data.frame(x, x2, y)
model <- lm(y ~ x + x2, data = dat)

p <- ggplot(dat, aes(x, y)) +
  geom_point(color = "gray60") +
  geom_slice(model, predict_vars = list(x2 = c(0, 4))) +
  geom_slice_text(style = "value") +
  labs(title = "gt_03: style = \"value\" — bare values, no variable names",
       subtitle = "EXPECT: '0' and '4' at the right ends of the two lines")
p
