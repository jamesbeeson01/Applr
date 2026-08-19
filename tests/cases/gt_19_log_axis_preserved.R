# CASE: gt_19_log_axis_preserved
# TYPE: visual
# FUNC: geom_slice_text
# EXPECT: A log-10 x-axis (scale_x_log10) with two slices held at x2 = 0 and
#         4, labeled at their right ends. Adding a plain scale_x_continuous
#         for the expansion would flatten the axis to raw numbers; editing
#         the existing scale keeps the log transform, so the breaks stay at
#         powers of ten (1, 10, 100, 1000) and the lines stay straight against
#         the log axis. Silent, as in gt_18.

source("tests/_setup.R")
set.seed(123)

n <- 50
x <- 10^runif(n, 0, 3)
x2 <- runif(n, 0, 5)
y <- 2 * log10(x) + 2 * x2 + rnorm(n, sd = 0.5)
dat <- data.frame(x, x2, y)
model <- lm(y ~ log10(x) + x2, data = dat)

p <- ggplot(dat, aes(x, y)) +
  geom_point(color = "gray60") +
  scale_x_log10() +
  geom_slice(model, predict_vars = list(x2 = c(0, 4))) +
  geom_slice_text() +
  labs(title = "gt_19: A log-10 x-axis survives the expansion",
       subtitle = "EXPECT: breaks at powers of ten, straight lines, labels fit")
p
