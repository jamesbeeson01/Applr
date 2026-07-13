# CASE: gt_13_offset_scaled_axis
# TYPE: visual
# FUNC: geom_slice_text
# EXPECT: Same layout as gt_01 but the x-axis spans 0..50000 instead of
#         -10..10. Two parallel skyblue slices (x2 held at 0 and 4), labeled
#         "x2: 0" and "x2: 4" at their right ends. The gap between each line
#         end and its label must be the SAME small visual gap as in gt_01 —
#         the offset is in points, so it must not grow or shrink with the
#         axis's data units. A data-unit nudge tuned for gt_01 (~0.24 units)
#         would be invisible here; a proportional one is what the reference
#         emulates.

source("tests/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, 0, 50000)
x2 <- runif(n, 0, 5)
y <- 0.0004 * x + 2 * x2 + rnorm(n)
dat <- data.frame(x, x2, y)
model <- lm(y ~ x + x2, data = dat)

p <- ggplot(dat, aes(x, y)) +
  geom_point(color = "gray60") +
  geom_slice(model, predict_vars = list(x2 = c(0, 4))) +
  geom_slice_text() +
  labs(title = "gt_13: Point offset is constant on a large-unit x-axis",
       subtitle = "EXPECT: same small line-to-label gap as gt_01, x in 0..50000")
p
