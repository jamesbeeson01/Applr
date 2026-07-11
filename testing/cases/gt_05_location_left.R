# CASE: gt_05_location_left
# TYPE: visual
# FUNC: geom_slice_text
# EXPECT: Two parallel skyblue slices (x2 held at 0 and 4) with
#         location = "left": the "x2: 0" / "x2: 4" labels sit just past the
#         LEFT end of each line (right-aligned toward the line), not the
#         right; the x-range expansion moves to the left side accordingly.

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
  geom_slice_text(model, predict_vars = list(x2 = c(0, 4)), location = "left") +
  labs(title = "gt_05: location = \"left\"",
       subtitle = "EXPECT: 'x2: 0' and 'x2: 4' at the LEFT ends of the lines")
p
