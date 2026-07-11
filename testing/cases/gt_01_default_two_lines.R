# CASE: gt_01_default_two_lines
# TYPE: visual
# FUNC: geom_slice_text
# EXPECT: Two parallel skyblue slices (x2 held at 0 and 4). At the RIGHT end of
#         each line, a text label in the default "variable: value" style:
#         "x2: 0" on the lower line, "x2: 4" on the upper line. Label color
#         matches the line color (skyblue). Both labels sit a small CONSTANT
#         gap past the line end (offset in points, not label widths),
#         vertically centered, and the geom widens the x-range itself so the
#         labels fit — no manual scale expansion in this case.

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
  geom_slice_text() +
  labs(title = "gt_01: Default end-of-line labels, style = \"variable: value\"",
       subtitle = "EXPECT: 'x2: 0' and 'x2: 4' at the right ends, skyblue")
p
