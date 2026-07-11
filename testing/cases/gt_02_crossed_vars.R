# CASE: gt_02_crossed_vars
# TYPE: visual
# FUNC: geom_slice_text
# EXPECT: Six parallel skyblue slices — x2 in {0, 2, 4} crossed with x3 in
#         {0, 1} — which without labels would be indistinguishable. Each line's
#         right end carries a two-variable label joined with "; ":
#         "x2: 0; x3: 0", "x2: 0; x3: 1", ..., "x2: 4; x3: 1".
#         Labels are skyblue, one per line, none overlapping badly, all at the
#         same constant gap past their line ends; the geom widens the x-range
#         itself to fit the longest label.

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
  geom_slice_text() +
  labs(title = "gt_02: Crossed predict_vars, default labels",
       subtitle = "EXPECT: six lines each labeled 'x2: v; x3: v' at the right end")
p
