# CASE: se_02_slider_breaks
# TYPE: widget
# FUNC: slice_explore
# EXPECT: One slider for x2 with exactly FOUR steps (0, 2, 5, 9) — slider_breaks
#         makes it deliberately jumpy, not continuous. The line starts at the
#         break nearest x2's mean (5: mean is 4.665) and jumps between four
#         distinct positions as the slider moves; larger x2 moves the line up
#         (coefficient +2). Console: one Sliders message showing x2 starting
#         at 5.

source("testing/_setup.R")
set.seed(42)

n <- 60
dat <- data.frame(x = runif(n, 0, 10), x2 = runif(n, 0, 9))
dat$y <- 3 + 1.5 * dat$x + 2 * dat$x2 + rnorm(n, sd = 2)
model <- lm(y ~ x + x2, data = dat)

slice_explore(model, sliders = x2, slider_breaks = c(0, 2, 5, 9))
