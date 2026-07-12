# CASE: s2_02_additive_default
# TYPE: visual
# FUNC: slice_2d
# EXPECT: Scatter of x vs y (y ~ x + x_pos) with one straight slice line,
#         x_pos held at its default (mean, with a console message) and shown
#         in the caption above the plot. A second console message reports
#         x_axis defaulting to the first x variable (x).

source("testing/_setup.R")
set.seed(123)

n <- 50
x <- runif(n, -10, 10)
x_pos <- runif(n, 0, 10)
y <- x + x_pos
model <- lm(y ~ x + x_pos)

slice_2d(model)
