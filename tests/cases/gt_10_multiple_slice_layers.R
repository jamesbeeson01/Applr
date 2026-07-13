# CASE: gt_10_multiple_slice_layers
# TYPE: visual
# FUNC: geom_slice_text
# EXPECT: The same model drawn as TWO separate geom_slice layers — x2 held at
#         0 (blue line) and 1 (red line). geom_slice_text() merges the layers
#         as if one layer had predict_vars = list(x2 = c(0, 1)): the blue line
#         gets a BLUE "x2: 0" label, the red line a RED "x2: 1" label, both at
#         the right line ends with the usual constant gap and auto x-margin.

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
x2 <- runif(n, 0, 2)
y <- x + 6 * x2 + rnorm(n)
dat <- data.frame(x, x2, y)
model <- lm(y ~ x + x2, data = dat)

p <- ggplot(dat, aes(x, y)) +
  geom_point(color = "gray60") +
  geom_slice(model, predict_vars = list(x2 = 0), color = "blue") +
  geom_slice(model, predict_vars = list(x2 = 1), color = "red") +
  geom_slice_text() +
  labs(title = "gt_10: one geom_slice_text() labels two geom_slice layers",
       subtitle = "EXPECT: blue 'x2: 0' on the blue line, red 'x2: 1' on the red line")
p
