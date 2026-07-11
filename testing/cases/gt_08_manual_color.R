# CASE: gt_08_manual_color
# TYPE: visual
# FUNC: geom_slice_text
# EXPECT: Two parallel skyblue slices (x2 held at 0 and 4), but the "x2: v"
#         labels are BLACK, not skyblue — a manual color = "black" on
#         geom_slice_text overrides the inherit-the-line-color default.

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
  geom_slice_text(model, predict_vars = list(x2 = c(0, 4)), color = "black") +
  labs(title = "gt_08: manual label color overrides line color",
       subtitle = "EXPECT: skyblue lines, BLACK 'x2: 0'/'x2: 4' labels")
p
