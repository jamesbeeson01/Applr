# CASE: gs_22_xaxis_inverse
# TYPE: visual
# FUNC: geom_slice
# EXPECT: Model y ~ I(1/x), plotted with 1/x on the x-axis. Data is noise-free
#         (y = 5/x + 2 exactly, R^2 = 1), so the slice must be ONE straight
#         line of slope 5 and intercept 2, passing exactly through every
#         point. No errors.
#         KNOWN ISSUE: currently warns "Computation failed in stat_slice():
#         Can't convert a call to a string" and draws no slice line.

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, 0.5, 10)
y <- 5 / x + 2
model <- lm(y ~ I(1/x))

p <- ggplot(data.frame(x, y), aes(1/x, y)) +
  geom_point(color = "steelblue") +
  geom_slice(model) +
  labs(title = "gs_22: 1/x on the x-axis (y ~ I(1/x))",
       subtitle = "EXPECT: Straight line, slope 5, exactly through all points")
p
